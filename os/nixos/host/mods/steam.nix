{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
		mangohud # overlay showing cpu / gpu load, etc
    gamescope
		protonup
		lutris
  ];

	programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers

    gamescopeSession.enable = true;
  };

  # VR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  #pkgs.alvr.override {

  #};

}
