{
  lib,
  pkgs,
  inputs,
  repoRoot,
  repoEntries,
  ...
}:
let
  registry = import (repoRoot + "/skills/sources.nix") { inherit lib pkgs inputs; };
  selected = lib.foldl' (acc: set: acc // set) { } registry.globalSkills;
in
{
  imports = [ inputs.agent-workspace.homeManagerModules.default ];
  spreadconfig.scriptFiles = repoEntries "modules/home/agent-skills/scripts";
  programs.agent-workspace = {
    enable = true;
    catalog = registry.catalog;
    skills = builtins.attrNames selected;
    targets.claude.enable = true;
    # Preserve per-skill missing-entry installation and existing-entry skipping.
    onConflict = lib.mkDefault "skip";
    cleanup = lib.mkDefault false;
  };
}
