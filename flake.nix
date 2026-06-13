{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old-a6c3b1b.url = "github:nixos/nixpkgs/a6c3b1bbaa0d39d37e8472438c81c7bd7989e453";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    frontend-design-skill = {
      url = "github:Aston1690/frontend-design";
      flake = false;
    };
    obsidian-skills.url = "github:kepano/obsidian-skills";
    obsidian-skills.flake = false;
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    web-artifacts-builder-skill = {
      url = "github:CuriousAquarius/claude-skill-web-artifacts-builder";
      flake = false;
    };
    web-interface-guidelines = {
      url = "github:vercel-labs/web-interface-guidelines";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      localOverlay = final: _: import ./packages { pkgs = final; };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            rocmSupport = true;
          };
          overlays = [ localOverlay ];
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

      mkHostContext =
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
        {
          inherit
            system
            hostName
            hostDir
            repoRoot
            pkgsPinned
            hostProfile
            ;
        };

      mkHost =
        args:
        let
          hostContext = mkHostContext args;
          inherit (hostContext)
            system
            hostName
            hostDir
            repoRoot
            pkgsPinned
            hostProfile
            ;
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
            inputs.sops-nix.nixosModules.sops
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
