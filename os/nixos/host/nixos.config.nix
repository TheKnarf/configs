{ config, pkgs, lib, ... }:

{
  imports = [
    # Hardware configuration
    ./nixos.hardware.nix

    # Modules
    ./mods/steam.nix
    ./mods/audio-video.nix
    ./mods/virtual.nix
    ./mods/gnome-x11.nix
    ./mods/tailscale.nix
    ./mods/moonlight.nix
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    hostName = "nixos";

    # Enable wake on lan
    interfaces.enp5s0.wakeOnLan.enable = true;
  };

  # Time zone & locale
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "no";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.knarf = {
    isNormalUser = true;
    description = "Knarf";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "seat" # seatd group
      "incus-admin"
      "incus"
    ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tmux
    bash
    home-manager
    xrdp
    zsh
    pciutils
    gnumake
  ];

  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.xrdp.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
