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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
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
    in
    {
      devShells.x86_64-linux.default =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
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
                pinnedPkgs = mkPinnedPkgs system;
              };
              home-manager.users.spreadzhao = {
                imports = [
                  ./host/thinkbook/home.nix
                ];
              };
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
            }
          ];
        };
      };
    };
}
