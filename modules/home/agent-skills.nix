{
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

  skillFiles =
    root: skills:
    lib.mapAttrs' (
      name: value:
      let
        skill = normalizeSkill name value;
      in
      lib.nameValuePair "${root}/${skill.target}" {
        inherit (skill) source recursive force;
      }
    ) skills;
in
{
  home.file =
    (skillFiles ".agents/skills" (registry.user or { }))
    // (skillFiles ".codex/skills" (registry.codex or { }))
    // (skillFiles ".claude/skills" (registry.claude or { }));
}
