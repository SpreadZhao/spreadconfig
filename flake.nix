{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # desktop1 graphics fallback: last working Generation 47 package set.
    nixpkgs-desktop1-graphics.url = "github:nixos/nixpkgs/e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa";
    # antigravity-nix = {
    #   url = "github:jacopone/antigravity-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
    fzf-popup = {
      url = "github:SpreadZhao/fzf-popup/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-input-watcher = {
      url = "github:SpreadZhao/flake-input-watcher/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notification-history = {
      url = "github:SpreadZhao/notification-history/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fzf-popup.follows = "fzf-popup";
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
    yt-dlp-downloader-skill = {
      url = "git+https://github.com/MapleShaw/yt-dlp-downloader-skill.git?ref=master";
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
          };
        };

      androidTemplate = {
        path = ./templates/android;
        description = "Android development environment with project-local agent skills";
      };
      workspaceTemplate = {
        path = ./templates/workspace;
        description = "Independent workspace with centrally maintained agent skills";
      };

      mkHostContext = import ./hosts/lib { inherit (nixpkgs) lib; };
      hostNames = nixpkgs.lib.filter (name: builtins.pathExists (./hosts + "/${name}/host.nix")) (
        builtins.attrNames (builtins.readDir ./hosts)
      );
      hosts = nixpkgs.lib.genAttrs hostNames (
        name:
        mkHostContext {
          inherit name;
          declaration = import (./hosts + "/${name}/host.nix");
        }
      );
      repoRoot = ./.;
      mkWorkspace = import ./lib/workspace { inherit inputs repoRoot; };
      repoWorkspace = mkWorkspace {
        systems = [ "x86_64-linux" ];
        skills = [
          "spreadconfig-nix"
          "nixos-best-practices"
        ];
        claude = true;
        packages =
          pkgs: with pkgs; [
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

      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit (host) system;
          specialArgs = {
            inherit
              inputs
              host
              repoRoot
              ;
          };
          modules = [
            ./modules/nixos
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit
                    inputs
                    host
                    repoRoot
                    ;
                };
                users.spreadzhao = {
                  imports = [
                    inputs.codex-desktop-linux.homeManagerModules.default
                    inputs.nixvim.homeModules.nixvim
                    ./modules/home
                  ]
                  ++ host.modules.home;
                };
              };
            }
          ]
          ++ host.modules.nixos;
        };
    in
    {
      lib = {
        inherit hosts mkWorkspace;
        mkHost = mkHostContext;
      };

      checks.x86_64-linux.host-context =
        let
          pkgs = mkPkgs "x86_64-linux";
          passed = import ./tests/host-context.nix {
            inherit (nixpkgs) lib;
            mkHost = mkHostContext;
            inherit hosts;
          };
        in
        assert passed;
        pkgs.runCommand "host-context-check" { } "touch $out";

      checks.x86_64-linux.mutable-files =
        let
          pkgs = mkPkgs "x86_64-linux";
          passed = import ./tests/mutable-files.nix {
            inherit (nixpkgs) lib;
            inherit repoRoot;
          };
        in
        assert passed;
        pkgs.runCommand "mutable-files-check" { } "touch $out";

      checks.x86_64-linux.workspace =
        let
          pkgs = mkPkgs "x86_64-linux";
        in
        pkgs.runCommand "workspace-regression-check"
          {
            nativeBuildInputs = [
              pkgs.python3
              pkgs.bash
              pkgs.jq
            ];
          }
          ''
            cp -R ${repoRoot} source
            chmod -R u+w source
            patchShebangs source
            cd source
            python3 tests/workspace-activation.py
            python3 tests/skill-paths.py
            touch "$out"
          '';

      checks.x86_64-linux.workspace-skills = repoWorkspace.checks.x86_64-linux.workspace;

      devShells = repoWorkspace.devShells;

      templates = {
        default = workspaceTemplate;
        workspace = workspaceTemplate;
        android = androidTemplate;
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs (_: mkHost) hosts;
    };
}
