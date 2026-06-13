{ config, pkgs, ... }:

let
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

    # Use wrapped Steam with wait4 fix and GPU acceleration flags
    package = steam-with-fixes;
  };

  # VR
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
}
