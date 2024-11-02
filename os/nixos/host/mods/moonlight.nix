{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
