{ config, pkgs, ... }:

{
  imports = [
		./hardware-configuration.nix
		./steam.nix
		./audio-video.nix
		<home-manager/nixos>
	];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.hostName = "nixos";
  networking.interfaces.enp5s0.wakeOnLan.enable = true;
  networking.networkmanager.enable = true;

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
		];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # System packages (allow unfree packages)
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tmux
    bash
    home-manager
    zsh
    kitty
    pciutils
  ];

  programs.zsh.enable = true;

  # enable docker
  virtualisation.docker.enable = true;

  home-manager.users.knarf = { pkgs, ... }: {
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
