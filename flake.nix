{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old-dd9b079.url = "github:nixos/nixpkgs/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
    nixpkgs-old-a6c3b1b.url = "github:nixos/nixpkgs/a6c3b1bbaa0d39d37e8472438c81c7bd7989e453";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkPackages = system: import ./packages { pkgs = mkPkgs system; };

      mkPinnedPkgs =
        system:
        nixpkgs.lib.mapAttrs' (
          name: input:
          nixpkgs.lib.nameValuePair
            (nixpkgs.lib.strings.replaceStrings [ "-" ] [ "_" ] (nixpkgs.lib.removePrefix "nixpkgs-" name))
            (
              import input {
                inherit system;
                config.allowUnfree = true;
              }
            )
        ) (nixpkgs.lib.filterAttrs (name: _: nixpkgs.lib.hasPrefix "nixpkgs-old-" name) inputs);

      mkHost =
        {
          name,
          system ? "x86_64-linux",
        }:
        let
          hostName = name;
          hostDir = ./hosts + "/${hostName}";
          repoRoot = ./.;
          pkgsPinned = mkPinnedPkgs system;
          hostProfile = {
            nixos = import (hostDir + "/nixos/profile.nix");
            home = import (hostDir + "/home/profile.nix");
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              pkgsPinned
              hostName
              repoRoot
              hostProfile
              ;
          };
          modules = [
            ./modules/nixos
            (hostDir + "/configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  pkgsPinned
                  hostName
                  repoRoot
                  hostProfile
                  ;
              };
              home-manager.users.spreadzhao = {
                imports = [
                  inputs.nixvim.homeModules.nixvim
                  ./modules/home
                  (hostDir + "/home.nix")
                ];
              };
            }
          ];
        };
    in
    {
      devShells.x86_64-linux.default =
        let
          system = "x86_64-linux";
          pkgs = mkPkgs system;
        in
        pkgs.mkShell {
          packages = with pkgs; [
            deadnix
            git
            jq
            nixfmt
            nixfmt-tree
            ripgrep
            shellcheck
            shfmt
            statix
          ];
        };

      packages.x86_64-linux = mkPackages "x86_64-linux";

      nixosConfigurations = {
        thinkbook = mkHost { name = "thinkbook"; };
        zephyrus-m16 = mkHost { name = "zephyrus-m16"; };
      };
    };
}
