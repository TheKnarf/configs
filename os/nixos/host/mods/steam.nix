{ config, pkgs, xdg-desktop-portal-gamescope, ... }:

let
  # Steam Big Picture's "Switch to Desktop" calls this binary. We write the
  # chosen session and end the user's session; greetd then relaunches the
  # session dispatcher which reads the file. Must live inside Steam's FHS
  # sandbox (extraPackages) — the system-wide PATH isn't visible to Steam.
  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    target="''${1:-gamescope}"
    mkdir -p "$HOME/.local/state"
    echo "$target" > "$HOME/.local/state/session-select"
    # End the current session so greetd relaunches the dispatcher with the
    # new selection. We kill the compositor (gamescope or weston) — both are
    # user-owned so no auth needed, and the dispatcher exits when they do.
    # Gamescope renames itself to "gamescope-wl" in wayland mode, so we
    # match the substring rather than using -x.
    /run/current-system/sw/bin/pkill -KILL -u "$(id -u)" gamescope 2>/dev/null
    /run/current-system/sw/bin/pkill -KILL -u "$(id -u)" -x weston 2>/dev/null
    true
  '';

  # Minimal DBus stub implementing the SessionManagement1 interface of
  # com.steampowered.SteamOSManager1. Steam Big Picture's "Switch to
  # Desktop" calls SwitchToDesktopMode here; we forward to the script.
  pythonForDbus = pkgs.python3.withPackages (ps: [ ps.dbus-python ps.pygobject3 ]);
  steamosManagerStub = pkgs.writeShellScriptBin "steamos-manager-stub" ''
    exec ${pythonForDbus}/bin/python3 ${pkgs.writeText "steamos-manager-stub.py" ''
      import subprocess
      import dbus
      import dbus.service
      import dbus.mainloop.glib
      from gi.repository import GLib

      BUS = 'com.steampowered.SteamOSManager1'
      IFACE = 'com.steampowered.SteamOSManager1.SessionManagement1'
      PATH = '/com/steampowered/SteamOSManager1'

      class SessionManagement(dbus.service.Object):
          def __init__(self, bus, path):
              super().__init__(bus, path)

          @dbus.service.method(IFACE, in_signature="", out_signature="")
          def SwitchToDesktopMode(self):
              subprocess.Popen(['/run/current-system/sw/bin/steamos-session-select', 'desktop'])

          @dbus.service.method(IFACE, in_signature="", out_signature="")
          def SwitchToGameMode(self):
              subprocess.Popen(['/run/current-system/sw/bin/steamos-session-select', 'gamescope'])

      dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
      bus = dbus.SessionBus()
      name = dbus.service.BusName(BUS, bus, do_not_queue=True)
      obj = SessionManagement(bus, PATH)
      GLib.MainLoop().run()
    ''}
  '';

  # DBus .service file so the broker treats the name as activatable.
  # Clients (Steam) that check ListActivatableNames or look for a .service
  # file on disk will see SteamOSManager1 as "supported".
  steamosManagerStubService = pkgs.runCommand "steamos-manager-stub-dbus" { } ''
    mkdir -p $out/share/dbus-1/services
    cat > $out/share/dbus-1/services/com.steampowered.SteamOSManager1.service <<EOF
    [D-BUS Service]
    Name=com.steampowered.SteamOSManager1
    Exec=${steamosManagerStub}/bin/steamos-manager-stub
    EOF
  '';

  # Fix for Steam GPU topology race condition where ThreadGetProcessExitCode
  # fails with ECHILD because steamsysinfo exits before Steam checks it.
  # This library intercepts wait4() to cache exit statuses and return them
  # when the original call fails with ECHILD.
  steam-wait4-fix = pkgs.pkgsi686Linux.stdenv.mkDerivation {
    name = "steam-wait4-fix";
    src = ./steam-wait4fix/wait4fix.c;
    nativeBuildInputs = [ pkgs.patchelf ];
    unpackPhase = "cp $src wait4fix.c";
    buildPhase = ''
      gcc -shared -fPIC -o libsteamwait4fix.so wait4fix.c -ldl -lpthread
    '';
    # Strip RPATH/RUNPATH so library uses FHS container's /lib32 glibc
    installPhase = ''
      mkdir -p $out/lib
      patchelf --remove-rpath libsteamwait4fix.so
      cp libsteamwait4fix.so $out/lib/
    '';
    dontPatchELF = true;
  };

  # Wrapped Steam package with GPU acceleration and wait4 fix
  steam-with-fixes = pkgs.steam.override {
    extraEnv = {
      LD_PRELOAD = "${steam-wait4-fix}/lib/libsteamwait4fix.so";
      # Force Chromium (steamwebhelper, where Big Picture's UI lives) to use
      # the X11 Ozone backend. Otherwise NIXOS_OZONE_WL=1 (set system-wide)
      # makes Chromium a native Wayland client — Steam's main binary calls
      # XTestFakeKeyEvent into XWayland, but the focused field would be a
      # Wayland surface, so synthetic keys never reach it.
      NIXOS_OZONE_WL = "0";
    };
    extraArgs = "-cef-force-gpu -cef-ignore-gpu-blocklist";
  };
in
{
  environment.systemPackages = with pkgs; [
    mangohud # overlay showing cpu / gpu load, etc
    gamescope
    protonup-ng
    lutris
    steamos-session-select
    steamosManagerStub
  ];

  # Register the DBus .service file on the host session bus, so the name
  # appears in ListActivatableNames and the broker can autostart the stub.
  services.dbus.packages = [ steamosManagerStubService ];

  # Also keep starting the stub at user login so it's already running
  # (the .service file would activate it on demand anyway, but autostart
  # avoids first-call latency).
  systemd.user.services.steamos-manager-stub = {
    description = "SteamOSManager DBus stub for non-Deck systems";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${steamosManagerStub}/bin/steamos-manager-stub";
      Restart = "on-failure";
    };
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  hardware.steam-hardware.enable = true;

  # xdg-desktop-portal is required by Steam in gamescope-session. The
  # gamescope-specific backend (from Jovian) provides the key-input portal
  # used by Steam's on-screen keyboard.
  xdg.portal = {
    enable = true;
    extraPortals = [
      xdg-desktop-portal-gamescope
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gamescope" "gtk" ];
  };

  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers

    gamescopeSession.enable = true;

    # Use wrapped Steam with wait4 fix and GPU acceleration flags
    package = steam-with-fixes;

    # Make steamos-session-select and the SteamOSManager .service file
    # visible inside Steam's FHS sandbox. Steam looks at /usr/share/dbus-1/
    # to decide whether SteamOSManager is supported on this system.
    extraPackages = [ steamos-session-select steamosManagerStubService ];
  };

  # VR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
}
