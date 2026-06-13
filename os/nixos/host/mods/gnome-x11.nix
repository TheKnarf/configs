{ config, pkgs, ... }:

let
  # Persistent file recording which session to launch next.
  # Steam's "Switch to Desktop" calls steamos-session-select to update it.
  sessionStateFile = "$HOME/.local/state/session-select";

  westonExec = pkgs.writeShellScript "weston-exec" ''
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_SESSION_TYPE=wayland
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 700 "$XDG_RUNTIME_DIR"
    fi
    exec ${pkgs.weston}/bin/weston --backend=drm --log=/tmp/weston-$(id -un).log
  '';

  gamescopeExec = pkgs.writeShellScript "gamescope-exec" ''
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_SESSION_TYPE=wayland
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 700 "$XDG_RUNTIME_DIR"
    fi
    exec /run/current-system/sw/bin/steam-gamescope >/tmp/gamescope-$(id -un).log 2>&1
  '';

  # Dispatcher: reads the session state file and runs the chosen session.
  # Defaults to gamescope (Steam Big Picture). The state file is written
  # by the `steamos-session-select` binary (defined in steam.nix).
  loginSession = pkgs.writeShellScript "login-session" ''
    mkdir -p "$(dirname ${sessionStateFile})"
    case "$(cat ${sessionStateFile} 2>/dev/null)" in
      desktop|plasma|weston) exec ${westonExec} ;;
      *) exec ${gamescopeExec} ;;
    esac
  '';
in
{
  environment.systemPackages = with pkgs; [
    kitty         # Terminal emulator
    weston        # Wayland compositor (kept as fallback / desktop session)
    foot          # Terminal for weston
  ];

  services.desktopManager = {
    gnome.enable = true;
  };

  # greetd in single-user TV mode: always autologin as knarf, no greeter.
  # The session command is a dispatcher that picks gamescope (default) or
  # weston based on $HOME/.local/state/session-select. To switch sessions
  # use `steamos-session-select [gamescope|desktop]`, which ends the
  # session and lets greetd relaunch the dispatcher with the new choice.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${loginSession}";
        user = "knarf";
      };
    };
  };

  # Ensure weston can access DRM
  security.wrappers = { };
  hardware.graphics.enable = true;

  services.autosuspend.enable = false;

  # Disable GNOME idle suspend via dconf (applied system-wide)
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
    sleep-inactive-ac-timeout=0
    sleep-inactive-battery-timeout=0
  '';

  # ref https://github.com/NixOS/nixpkgs/issues/100390#issuecomment-867830400
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
        {
            return polkit.Result.NO;
        }
    });
  '';
}
