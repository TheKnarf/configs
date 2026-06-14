{ config, pkgs, ... }:

let
  # Fix for Steam GPU topology race condition where ThreadGetProcessExitCode
  # fails with ECHILD because steamsysinfo exits before Steam checks it.
  # This library intercepts wait4() to cache exit statuses and return them
  # when the original call fails with ECHILD.
  #
  # Built for both 32-bit and 64-bit so ld.so's $LIB substitution picks
  # the matching one for each Steam subprocess; otherwise 64-bit children
  # log "wrong ELF class" warnings for the 32-bit lib.
  mkWait4Fix = { stdenv, libDir }: stdenv.mkDerivation {
    name = "steam-wait4-fix-${libDir}";
    src = ./steam-wait4fix/wait4fix.c;
    nativeBuildInputs = [ pkgs.patchelf ];
    unpackPhase = "cp $src wait4fix.c";
    buildPhase = ''
      gcc -shared -fPIC -o libsteamwait4fix.so wait4fix.c -ldl -lpthread
    '';
    # Strip RPATH/RUNPATH so library uses FHS container's glibc
    installPhase = ''
      mkdir -p $out/${libDir}
      patchelf --remove-rpath libsteamwait4fix.so
      cp libsteamwait4fix.so $out/${libDir}/
    '';
    dontPatchELF = true;
  };

  steam-wait4-fix = pkgs.symlinkJoin {
    name = "steam-wait4-fix";
    # ld.so's $LIB expands to "lib" for 32-bit x86 and "lib64" for x86_64.
    paths = [
      (mkWait4Fix { stdenv = pkgs.pkgsi686Linux.stdenv; libDir = "lib";   })
      (mkWait4Fix { stdenv = pkgs.stdenv;               libDir = "lib64"; })
    ];
  };

  # Wrapped Steam package with GPU acceleration and wait4 fix.
  # Pass both libs colon-separated so pressure-vessel (Steam Runtime
  # container) can detect each one's arch and route to ${PLATFORM}
  # automatically. Using $LIB doesn't survive pressure-vessel's
  # LD_PRELOAD rewrite.
  steam-with-fixes = pkgs.steam.override {
    extraEnv = {
      LD_PRELOAD = "${steam-wait4-fix}/lib/libsteamwait4fix.so:${steam-wait4-fix}/lib64/libsteamwait4fix.so";
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
