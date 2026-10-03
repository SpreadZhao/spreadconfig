{ inputs, repoRoot }:
{
  systems ? [
    "x86_64-linux"
    "aarch64-linux"
  ],
  skills ? [ ],
  packages ? (_: [ ]),
  claude ? false,
  instructions ? "",
  # Additional pinned sources (e.g. official Android skills) follow the same
  # validation and ownership rules, and may not shadow the central catalog.
  extraSkills ? { },
  shellHook ? "",
}:
let
  inherit (inputs.nixpkgs) lib;
  safeName = name: builtins.match "[a-zA-Z0-9][a-zA-Z0-9._-]*" name != null;
  checked =
    assert lib.assertMsg (lib.all builtins.isString (
      skills ++ systems
    )) "mkWorkspace skills and systems must contain strings";
    true;
  perSystem = lib.genAttrs systems (
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      registry = import (repoRoot + "/skills/sources.nix") { inherit lib pkgs inputs; };
      collisions = lib.intersectLists (builtins.attrNames registry.catalog) (
        builtins.attrNames extraSkills
      );
      catalog = registry.catalog // lib.mapAttrs (_: source: { inherit source; }) extraSkills;
      selected = lib.unique (skills ++ builtins.attrNames extraSkills);
      unknownSkills = lib.subtractLists (builtins.attrNames catalog) selected;
      selection =
        assert lib.assertMsg (
          collisions == [ ]
        ) "Conflicting skill names: ${lib.concatStringsSep ", " collisions}";
        assert lib.assertMsg (
          unknownSkills == [ ]
        ) "Unknown workspace skills: ${lib.concatStringsSep ", " unknownSkills}";
        assert lib.assertMsg (lib.all safeName selected) "Unsafe workspace skill name";
        map (
          name:
          let
            entry = catalog.${name};
          in
          {
            inherit name;
            source = "${entry.source}";
          }
          // lib.optionalAttrs (entry ? relativePath) { inherit (entry) relativePath; }
        ) selected;
      # This validates all pinned sources before shellHook can touch a workspace.
      # The tree also retains generated/external sources after leaving the shell.
      bundle = pkgs.runCommand "workspace-skill-sources" { } (
        "mkdir -p \"$out/skills\"\n"
        + lib.concatMapStringsSep "\n" (entry: ''
          test -f ${lib.escapeShellArg "${entry.source}/SKILL.md"} || {
            echo ${lib.escapeShellArg "Missing SKILL.md for ${entry.name}: ${entry.source}"} >&2
            exit 1
          }
          ln -s ${lib.escapeShellArg entry.source} "$out/skills/${entry.name}"
        '') selection
      );
      manifest = pkgs.writeText "workspace-manifest.json" (
        builtins.toJSON {
          schemaVersion = 2;
          inherit claude instructions;
          # The catalog fixes each source: local checkout or a supplied store source.
          skills = map (
            entry:
            {
              inherit (entry) name;
            }
            // (if entry ? relativePath then { inherit (entry) relativePath; } else { inherit (entry) source; })
          ) selection;
          storeRoot = toString bundle;
        }
      );
      activate = pkgs.writeShellScript "prepare-workspace" ''
        export PATH=${lib.makeBinPath [ pkgs.nix ]}:"$PATH"
        exec ${pkgs.python3}/bin/python3 ${./activate.py} ${manifest}
      '';
    in
    {
      devShell = pkgs.mkShell {
        packages = if builtins.isFunction packages then packages pkgs else packages;
        shellHook = ''
          # Fail the whole entry, including `nix develop -c`, on a conflict.
          if ! spreadconfig_workspace_root="$(${activate})"; then
            echo "Workspace preparation failed; resolve the conflict and enter again." >&2
            exit 1
          fi
          export AGENT_WORKSPACE_ROOT="$spreadconfig_workspace_root"
          unset spreadconfig_workspace_root
          ${shellHook}
        '';
      };
      check = bundle;
    }
  );
in
assert checked;
{
  devShells = lib.mapAttrs (_: value: { default = value.devShell; }) perSystem;
  checks = lib.mapAttrs (_: value: { workspace = value.check; }) perSystem;
}
