{
  description = "NixOS and Home-manager config";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
      #url = "github:jopejoe1/nixpkgs/alvr-src";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = { nixpkgs, home-manager, hyprland, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "${system}";
        config = {
          allowUnfree = true;
        };
      };
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

        specialArgs = {inherit user;};
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
