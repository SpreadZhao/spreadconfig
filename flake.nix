{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old-dd9b079.url = "github:nixos/nixpkgs/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
    nixpkgs-old-a6c3b1b.url = "github:nixos/nixpkgs/a6c3b1bbaa0d39d37e8472438c81c7bd7989e453";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    file-manager-dbus.url = "./packages/file-manager-dbus";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixpkgs-old-dd9b079,
      nixpkgs-old-a6c3b1b,
      ...
    }@inputs:
    let
    in
    {
      nixosConfigurations = {
        thinkbook = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./host/thinkbook/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                pkgs-old-dd9b079 = import nixpkgs-old-dd9b079 {
                  inherit system;
                  config.allowUnfree = true;
                };
                pkgs-old-a6c3b1b = import nixpkgs-old-a6c3b1b {
                  inherit system;
                  config.allowUnfree = true;
                };
              };
              home-manager.users.spreadzhao = {
                imports = [
                  ./host/thinkbook/home.nix
                ];
              };
              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
        desktop1 = nixpkgs.lib.nixosSystem {
          # system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.spreadzhao = {
                imports = [
                  ./home.nix
                ];
              };
              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
      };
    };
}
