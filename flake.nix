{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    wayprompt-nixpkgs.url = "github:nixos/nixpkgs/a6c3b1bbaa0d39d37e8472438c81c7bd7989e453";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hermes-agent.url = "github:NousResearch/hermes-agent";
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
    nixos-best-practices-skill = {
      url = "git+https://github.com/lihaoze123/my-claude-code.git?ref=main";
      flake = false;
    };
    drawio-skill = {
      url = "git+https://github.com/Agents365-ai/drawio-skill.git?ref=main";
      flake = false;
    };
    frontend-design-skill = {
      url = "git+https://github.com/Aston1690/frontend-design.git?ref=main";
      flake = false;
    };
    obsidian-skills = {
      url = "git+https://github.com/kepano/obsidian-skills.git?ref=main";
      flake = false;
    };
    personal-packages = {
      url = "github:SpreadZhao/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openai-skills = {
      url = "git+https://github.com/openai/skills.git?ref=main";
      flake = false;
    };
    web-artifacts-builder-skill = {
      url = "git+https://github.com/CuriousAquarius/claude-skill-web-artifacts-builder.git?ref=main";
      flake = false;
    };
    web-interface-guidelines = {
      url = "git+https://github.com/vercel-labs/web-interface-guidelines.git?ref=main";
      flake = false;
    };
    xiaohongshu-summarizer-skill = {
      url = "git+https://github.com/piekill/xiaohongshu-summarizer-skill.git?ref=main";
      flake = false;
    };
    textbridge.url = "github:SpreadZhao/textbridge";
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
          config = {
            allowUnfree = true;
            rocmSupport = true;
          };
        };

      androidTemplate = {
        path = ./templates/android;
        description = "Android development environment with project-local agent skills";
      };

      mkHostContext =
        {
          name,
          system ? "x86_64-linux",
        }:
        let
          hostName = name;
          hostDir = ./hosts + "/${hostName}";
          repoRoot = ./.;
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
            hostProfile
            ;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
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
                  hostName
                  repoRoot
                  hostProfile
                  ;
              };
              home-manager.users.spreadzhao = {
                imports = [
                  inputs.codex-desktop-linux.homeManagerModules.default
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

      templates = {
        default = androidTemplate;
        android = androidTemplate;
      };

      nixosConfigurations = {
        thinkbook = mkHost { name = "thinkbook"; };
        zephyrus-m16 = mkHost { name = "zephyrus-m16"; };
      };
    };
}
