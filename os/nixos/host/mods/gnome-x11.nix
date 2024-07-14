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
      gdm.wayland = false;
    };

    desktopManager = {
      gnome.enable = true;
    };
  };
}
