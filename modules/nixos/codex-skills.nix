{
  lib,
  pkgs,
  repoRoot,
  ...
}:

let
  registry = import (repoRoot + "/skills/sources.nix") {
    inherit lib pkgs;
  };

  normalizeSkill =
    name: value:
    if lib.isAttrs value && value ? source then
      {
        source = value.source;
        target = value.target or name;
      }
    else
      {
        source = value;
        target = name;
      };
in
{
  environment.etc = lib.mapAttrs' (
    name: value:
    let
      skill = normalizeSkill name value;
    in
    lib.nameValuePair "codex/skills/${skill.target}" {
      inherit (skill) source;
    }
  ) (registry.system or { });
}
