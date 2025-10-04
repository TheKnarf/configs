{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
		kitty         # Terminal emulator
    xorg.xinit
  ];

  services.xserver = {
    enable = true;

    displayManager = {
      gdm.enable = true;
      gdm.autoSuspend = false;
      gdm.wayland = false;
    };

    desktopManager = {
      gnome.enable = true;
    };
  };

  services.autosuspend.enable = false;

  # Disable GNOME idle suspend via dconf (applied system-wide)
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
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
