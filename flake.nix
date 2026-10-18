{
  description = "NixOS configuration";

  inputs = {
    naw = {
      url = "github:SpreadZhao/NAW";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    personal-skills = {
      url = "github:SpreadZhao/personal-skills";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # desktop1 graphics fallback: last working Generation 47 package set.
    nixpkgs-desktop1-graphics.url = "github:nixos/nixpkgs/e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa";
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
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
      mkHostContext = import ./lib/host-context.nix { inherit (nixpkgs) lib; };
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
      repoWorkspace = inputs.naw.lib.mkWorkspace {
        systems = [ "x86_64-linux" ];
        skills = {
          spreadconfig-nix = "${inputs.personal-skills}/skills/spreadconfig-nix";
          nixos-best-practices = "${inputs.nixos-best-practices-skill}/skills/nixos-best-practices";
        };
        targets = [
          "agents"
          "claude"
        ];
        # Keep repository policy in the source configuration, not generated AGENTS.md.
        instructions = ''
          ## Nix Switch Policy

          - For any Nix-related work in this repository, never execute `switch`; the user performs that step manually.
          - This includes `nixos-rebuild switch`, `home-manager switch`, `nh os switch`, `nh home switch`, and any wrapper or update script that invokes `switch`, including through its default arguments.
          - Evaluation, builds, formatting, and other checks that do not activate the configuration are allowed. When a switch is needed, provide the command for the user to run instead of executing it.
          - Requests to change, update, fix, or rebuild Nix configuration do not authorize an automatic switch. This repository-wide rule takes precedence over any skill or workflow that recommends running `switch`.

          ## Clean Delivery Policy

          - Deliver only the files, dependencies, configuration, and behavior needed for the requested result. Before finishing, actively review the working tree and clean up this task's temporary tests, fixtures, validation reports, logs, caches, intermediate outputs, and debug code or settings. Do not leave cleanup for the user.
          - Testing during development is encouraged, but temporary unit tests and other verification scripts belong outside the repository and must be removed after use. Keep tests in the delivered project only when the user explicitly asks to retain them. Remove test-only helpers, command-line options, and documentation references as well.
          - Prefer temporary, isolated environments such as `nix shell` or `nix develop` for tools needed only for testing. Remove packages and dependencies added solely for development, testing, or debugging from persistent configuration and profiles when they are not needed by the delivered result.
          - Stop temporary processes and services, undo temporary environment or configuration changes, and remove temporary files created for this task, including those outside the repository. Preserve anything that is part of the requested result.
          - Limit cleanup to changes and resources introduced by this task. Preserve the user's existing tools, data, tests, and unrelated modifications. Do not delete shared Nix Store contents or run broad garbage collection as a cleanup shortcut.
          - Cleanup must respect the Nix Switch Policy. If removing a live dependency or other temporary state requires a prohibited action, prepare the configuration change, report exactly what remains, and provide the manual command; do not execute `switch` or claim cleanup is complete.
        '';
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
        inherit hosts;
        mkHost = mkHostContext;
      };

      checks.x86_64-linux.workspace-skills = repoWorkspace.checks.x86_64-linux.workspace;

      devShells = repoWorkspace.devShells;

      nixosConfigurations = nixpkgs.lib.mapAttrs (_: mkHost) hosts;
    };
}
