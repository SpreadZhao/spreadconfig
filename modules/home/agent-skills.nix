{
  config,
  lib,
  pkgs,
  inputs,
  repoRoot,
  ...
}:

let
  registry = import (repoRoot + "/skills/sources.nix") {
    inherit
      lib
      pkgs
      inputs
      ;
  };

  normalizeSkill =
    name: value:
    if lib.isAttrs value && value ? source then
      {
        source = value.source;
        target = value.target or name;
        recursive = value.recursive or false;
        force = value.force or false;
      }
    else
      {
        source = value;
        target = name;
        recursive = false;
        force = false;
      };

  mergeSkillSets =
    value: if lib.isList value then lib.foldl' (skills: item: skills // item) { } value else value;

  homeDir = config.home.homeDirectory;
  validMissingPolicies = [
    "create"
    "fail"
    "skip"
  ];

  toHomeTargetRoot =
    root:
    if lib.hasPrefix "/" root then
      if lib.hasPrefix "${homeDir}/" root then
        lib.removePrefix "${homeDir}/" root
      else
        throw "skillDirs key '${root}' must be relative to $HOME or inside ${homeDir}"
    else
      root;

  toAbsoluteRoot = root: if lib.hasPrefix "/" root then root else "${homeDir}/${root}";

  normalizeDir =
    root: value:
    let
      dir =
        if lib.isAttrs value && (value ? skills || value ? onMissing) then value else { skills = value; };

      onMissing = dir.onMissing or "create";
    in
    if !(lib.elem onMissing validMissingPolicies) then
      throw "Invalid skillDirs onMissing value '${onMissing}' for '${root}'. Expected one of: ${lib.concatStringsSep ", " validMissingPolicies}"
    else
      {
        homeTargetRoot = toHomeTargetRoot root;
        absoluteRoot = toAbsoluteRoot root;
        inherit onMissing;
        skills = mergeSkillSets (dir.skills or { });
      };

  skillFiles =
    dir:
    lib.mapAttrs' (
      name: value:
      let
        skill = normalizeSkill name value;
      in
      lib.nameValuePair "${dir.homeTargetRoot}/${skill.target}" {
        inherit (skill) source recursive force;
      }
    ) dir.skills;

  legacySkillDirs =
    (lib.optionalAttrs (registry ? user) { ".agents/skills" = registry.user; })
    // (lib.optionalAttrs (registry ? codex) { ".codex/skills" = registry.codex; })
    // (lib.optionalAttrs (registry ? claude) { ".claude/skills" = registry.claude; });

  skillDirs = registry.skillDirs or legacySkillDirs;
  dirEntries = lib.mapAttrsToList normalizeDir skillDirs;
  homeFileDirs = lib.filter (dir: dir.onMissing != "skip") dirEntries;
  failDirs = lib.filter (dir: dir.onMissing == "fail") dirEntries;
  skipDirs = lib.filter (dir: dir.onMissing == "skip") dirEntries;

  checkMissingDirsScript = lib.concatMapStringsSep "\n" (dir: ''
    if [ ! -d ${lib.escapeShellArg dir.absoluteRoot} ]; then
      echo "Skill directory does not exist: ${dir.absoluteRoot}" >&2
      exit 1
    fi
  '') failDirs;

  installSkippedDirsScript =
    let
      installSkill =
        dir: name: value:
        let
          skill = normalizeSkill name value;
        in
        ''
          install_skill \
            ${lib.escapeShellArg dir.absoluteRoot} \
            ${lib.escapeShellArg skill.target} \
            ${lib.escapeShellArg (toString skill.source)} \
            ${lib.escapeShellArg (if skill.force then "1" else "0")}
        '';

      installDir = dir: ''
        if [ -d ${lib.escapeShellArg dir.absoluteRoot} ]; then
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (installSkill dir) dir.skills)}
        else
          echo "Skipping skills for missing directory: ${dir.absoluteRoot}"
        fi
      '';
    in
    ''
      install_skill() {
        local root="$1"
        local target_name="$2"
        local source="$3"
        local force="$4"
        local target="$root/$target_name"
        local current=""

        if [ -e "$target" ] || [ -L "$target" ]; then
          current="$(readlink "$target" || true)"
          if [ "$current" = "$source" ]; then
            return 0
          fi

          if [ "$force" = "1" ]; then
            rm -rf "$target"
          elif [ -L "$target" ] && [[ "$current" == /nix/store/* ]]; then
            rm -f "$target"
          else
            echo "Skill target already exists: $target" >&2
            exit 1
          fi
        fi

        mkdir -p "$(dirname "$target")"
        ln -s "$source" "$target"
      }

      ${lib.concatMapStringsSep "\n" installDir skipDirs}
    '';
in
{
  home.file = lib.foldl' (files: dir: files // skillFiles dir) { } homeFileDirs;

  home.activation =
    (lib.optionalAttrs (checkMissingDirsScript != "") {
      checkSkillDirectories = lib.hm.dag.entryBefore [ "writeBoundary" ] checkMissingDirsScript;
    })
    // (lib.optionalAttrs (skipDirs != [ ]) {
      installSkippedSkillDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] installSkippedDirsScript;
    });
}
