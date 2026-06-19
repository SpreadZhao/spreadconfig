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
  indexedSkipDirs = lib.imap0 (skipIndex: dir: dir // { inherit skipIndex; }) skipDirs;

  checkMissingDirsScript = lib.concatMapStringsSep "\n" (dir: ''
    if [ ! -d ${lib.escapeShellArg dir.absoluteRoot} ]; then
      echo "Skill directory does not exist: ${dir.absoluteRoot}" >&2
      exit 1
    fi
  '') failDirs;

  captureSkippedDirsScript = lib.concatMapStringsSep "\n" (
    dir:
    let
      dirWasPresent = "spreadconfig_skill_dir_exists_${toString dir.skipIndex}";
    in
    ''
      ${dirWasPresent}=0
      if [ -d ${lib.escapeShellArg dir.absoluteRoot} ]; then
        ${dirWasPresent}=1
      fi
    ''
  ) indexedSkipDirs;

  installSkippedDirsScript =
    let
      installSkill =
        dir: name: value:
        let
          skill = normalizeSkill name value;
        in
        ''
          echo "Installing skill ${skill.target} into ${dir.absoluteRoot}"
          install_skill \
            ${lib.escapeShellArg dir.absoluteRoot} \
            ${lib.escapeShellArg skill.target} \
            ${lib.escapeShellArg (toString skill.source)} \
            ${lib.escapeShellArg (if skill.force then "1" else "0")} \
            || return $?
        '';

      installDir =
        dir:
        let
          dirWasPresent = "spreadconfig_skill_dir_exists_${toString dir.skipIndex}";
          dirWasPresentRef = "$" + dirWasPresent;
        in
        ''
          if [ "${dirWasPresentRef}" = "1" ] || [ -d ${lib.escapeShellArg dir.absoluteRoot} ]; then
            mkdir -p ${lib.escapeShellArg dir.absoluteRoot} || return $?
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (installSkill dir) dir.skills)}
          else
            echo "Skipping skills for missing directory: ${dir.absoluteRoot}"
          fi
        '';
    in
    ''
      skill_install_log="$(mktemp "''${TMPDIR:-/tmp}/spreadconfig-skill-install.XXXXXX.log")"

      run_skill_installation() {
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
              echo "Skill target is already current: $target"
              return 0
            fi

            if [ "$force" = "1" ]; then
              echo "Replacing existing skill target because force is enabled: $target"
              rm -rf "$target" || return $?
            elif [ -L "$target" ] && [[ "$current" == /nix/store/* ]]; then
              echo "Replacing managed skill symlink: $target -> $current"
              rm -f "$target" || return $?
            else
              echo "Skill target already exists and is not managed: $target" >&2
              return 1
            fi
          fi

          mkdir -p "$(dirname "$target")" || return $?
          ln -s "$source" "$target" || return $?
        }

        ${lib.concatMapStringsSep "\n" installDir indexedSkipDirs}
      }

      if run_skill_installation >"$skill_install_log" 2>&1; then
        rm -f "$skill_install_log"
      else
        skill_install_status="$?"
        echo "Skill installation failed during Home Manager activation." >&2
        echo "Full skill installation log follows. Log file: $skill_install_log" >&2
        echo "----- skill installation log begin -----" >&2
        cat "$skill_install_log" >&2 || true
        echo "----- skill installation log end -----" >&2
        exit "$skill_install_status"
      fi
    '';
in
{
  home.file = lib.foldl' (files: dir: files // skillFiles dir) { } homeFileDirs;

  home.activation =
    (lib.optionalAttrs (checkMissingDirsScript != "") {
      checkSkillDirectories = lib.hm.dag.entryBefore [ "writeBoundary" ] checkMissingDirsScript;
    })
    // (lib.optionalAttrs (captureSkippedDirsScript != "") {
      captureSkippedSkillDirectories = lib.hm.dag.entryBefore [
        "writeBoundary"
      ] captureSkippedDirsScript;
    })
    // (lib.optionalAttrs (skipDirs != [ ]) {
      installSkippedSkillDirectories = lib.hm.dag.entryAfter [
        "linkGeneration"
      ] installSkippedDirsScript;
    });
}
