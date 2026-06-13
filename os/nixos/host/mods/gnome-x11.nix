{ config, pkgs, ... }:

let
  westonSession = pkgs.writeShellScript "weston-session" ''
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_SESSION_TYPE=wayland
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1

    # Ensure runtime dir exists with correct permissions
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
      mkdir -p "$XDG_RUNTIME_DIR"
      chmod 700 "$XDG_RUNTIME_DIR"
    fi

    # Log weston output for debugging
    exec ${pkgs.weston}/bin/weston --backend=drm --log=/tmp/weston-$(id -un).log
  '';
in
{
  environment.systemPackages = with pkgs; [
    kitty         # Terminal emulator
    weston        # Working Wayland compositor for this TV
    foot          # Terminal for weston
  ];

  services.desktopManager = {
    gnome.enable = true;
  };

  # Use greetd with tuigreet (TUI-based, works on console)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${westonSession}";
        user = "greeter";
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
