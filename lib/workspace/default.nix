{ inputs, repoRoot }:
# Preserve the spreadconfig catalog and historical entry point. All installation
# behavior belongs to the independent manager; no checkout-dependent sources.
args:
inputs.agent-workspace.lib.mkWorkspace (
  {
    catalog =
      pkgs:
      (import (repoRoot + "/skills/sources.nix") {
        inherit pkgs inputs;
        inherit (pkgs) lib;
      }).catalog;
  }
  // args
)
