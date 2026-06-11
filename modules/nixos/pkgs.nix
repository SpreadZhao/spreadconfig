{ repoRoot, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      rocmSupport = true;
    };

    # Keep overlays here because Home Manager uses the system package set.
    overlays = [
      (final: _: import (repoRoot + "/packages") { pkgs = final; })
    ];
  };
}
