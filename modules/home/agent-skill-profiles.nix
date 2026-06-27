{
  config,
  lib,
  pkgs,
  inputs,
  repoRoot,
  ...
}:

let
  workspaceRoot = config.xdg.userDirs.extraConfig.WORKSPACE;
  localSkillSource = name: "${workspaceRoot}/spreadconfig/skills/local/${name}";

  registry = import (repoRoot + "/skills/sources.nix") {
    inherit
      lib
      pkgs
      inputs
      localSkillSource
      workspaceRoot
      ;
  };

  validSkillTargets = [
    "agents"
    "claude"
    "codex"
  ];

  normalizeSkill =
    name: value:
    if lib.isAttrs value && value ? source then
      {
        source = value.source;
        target = value.target or name;
        targets = value.targets or [ "agents" ];
        force = value.force or false;
      }
    else
      {
        source = value;
        target = name;
        targets = [ "agents" ];
        force = false;
      };

  mergeSkillSets =
    value:
    if lib.isList value then
      lib.foldl' (skills: item: skills // mergeSkillSets item) { } value
    else
      value;

  profiles = registry.workspaceProfiles or { };

  validateSkillTargets =
    skill:
    let
      unknownTargets = lib.filter (target: !(lib.elem target validSkillTargets)) skill.targets;
    in
    if unknownTargets != [ ] then
      throw "Invalid targets for skill '${skill.target}': ${lib.concatStringsSep ", " unknownTargets}. Expected one of: ${lib.concatStringsSep ", " validSkillTargets}"
    else
      skill;

  profileRows = lib.flatten (
    lib.mapAttrsToList (
      profileName: profileValue:
      lib.flatten (
        lib.mapAttrsToList (
          skillName: value:
          let
            skill = validateSkillTargets (normalizeSkill skillName value);
          in
          map (
            targetName:
            "${profileName}\t${targetName}\t${skill.target}\t${toString skill.source}\t${
              if skill.force then "1" else "0"
            }"
          ) skill.targets
        ) (mergeSkillSets profileValue)
      )
    ) profiles
  );
in
{
  home.file = {
    ".config/spreadconfig/agent-skill-profiles.tsv".text =
      lib.concatStringsSep "\n" ([ "# profile\ttarget\tskill\tsource\tforce" ] ++ profileRows) + "\n";

    "workspaces/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${workspaceRoot}/spreadconfig/workspace/AGENTS.md";
  };
}
