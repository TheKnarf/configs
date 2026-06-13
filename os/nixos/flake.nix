{
  description = "NixOS and Home-manager config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
      #url = "github:jopejoe1/nixpkgs/alvr-src";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    ags.url = "github:Aylur/ags";

    # Jovian-NixOS — used only for the xdg-desktop-portal-gamescope package
    # (and related bits) so Steam Big Picture's on-screen keyboard can
    # inject keystrokes via libei. We do NOT enable the full Jovian stack.
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, hyprland, jovian, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "${system}";
        config = {
          allowUnfree = true;
        };
      };
      # Cherry-pick xdg-desktop-portal-gamescope from Jovian without
      # applying their full overlay (which would override gamescope etc).
      xdg-desktop-portal-gamescope = pkgs.callPackage
        "${jovian}/pkgs/xdg-desktop-portal-gamescope" { };
      user = "knarf";
    in {
      # Machines
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          ./host/nixos.config.nix
          home-manager.nixosModules.home-manager
          {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = import ./home-manager/home.nix;
          }
        ];

        specialArgs = {inherit user xdg-desktop-portal-gamescope;};
      };

      nixosConfigurations."chuwi" = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          ./host/chuwi.config.nix
          home-manager.nixosModules.home-manager
          {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = import ./home-manager/home.nix;
          }
        ];

        specialArgs = {inherit user;};
      };

      # Home manager
      homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          hyprland.homeManagerModules.default
          ./home-manager/home.nix
        ];

        extraSpecialArgs = {inherit user;};
      };
    };
}
