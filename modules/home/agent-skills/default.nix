{
  config,
  lib,
  pkgs,
  inputs,
  repoRoot,
  projDir,
  repoEntries,
  ...
}:

let
  localSkillSource = name: "${projDir}/skills/local/${name}";

  registry = import (repoRoot + "/skills/sources.nix") {
    inherit
      lib
      pkgs
      inputs
      localSkillSource
      ;
  };

  skillTargets = {
    agents = ".agents/skills";
    claude = ".claude/skills";
    codex = ".codex/skills";
  };
  validSkillTargets = builtins.attrNames skillTargets;

  normalizeSkill = name: value: {
    source = value.source;
    target = value.target or name;
    targets = value.targets or [ "agents" ];
    force = value.force or false;
  };

  mergeSkillSets =
    value:
    if lib.isList value then
      lib.foldl' (skills: item: skills // mergeSkillSets item) { } value
    else
      value;

  validateSkillTargets =
    skill:
    let
      unknownTargets = lib.filter (target: !(lib.elem target validSkillTargets)) skill.targets;
    in
    if unknownTargets != [ ] then
      throw "Invalid targets for skill '${skill.target}': ${lib.concatStringsSep ", " unknownTargets}. Expected one of: ${lib.concatStringsSep ", " validSkillTargets}"
    else
      skill;

  globalSkillsToSkillDirs =
    value:
    let
      skills = mergeSkillSets value;
      emptyTargetSkillDirs = lib.mapAttrs' (
        _: root:
        lib.nameValuePair root {
          skills = { };
        }
      ) skillTargets;

      targetSkillDirs = lib.foldl' (
        dirs: name:
        let
          skill = validateSkillTargets (normalizeSkill name skills.${name});
          skillValue = builtins.removeAttrs skill [ "targets" ];
        in
        lib.foldl' (
          nextDirs: target:
          let
            root = skillTargets.${target};
          in
          nextDirs
          // {
            ${root} = nextDirs.${root} // {
              skills = nextDirs.${root}.skills // {
                ${name} = skillValue;
              };
            };
          }
        ) dirs skill.targets
      ) emptyTargetSkillDirs (builtins.attrNames skills);
    in
    lib.filterAttrs (_: dir: dir.skills != { }) targetSkillDirs;

  skillDirs = globalSkillsToSkillDirs registry.globalSkills;
  skipDirs = lib.mapAttrsToList (root: dir: {
    absoluteRoot = "${config.home.homeDirectory}/${root}";
    inherit (dir) skills;
  }) skillDirs;
  indexedSkipDirs = lib.imap0 (skipIndex: dir: dir // { inherit skipIndex; }) skipDirs;

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
  home.sessionVariables.SPREADCONFIG_SOURCE_ROOT = lib.mkDefault projDir;
  spreadconfig.scriptFiles = repoEntries "modules/home/agent-skills/scripts";

  home.activation =
    (lib.optionalAttrs (captureSkippedDirsScript != "") {
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
