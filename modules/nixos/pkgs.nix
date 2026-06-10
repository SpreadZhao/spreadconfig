{ repoRoot, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      rocmSupport = true;
    };

    # Keep local packages available to system modules.
    overlays = [
      (final: _: import (repoRoot + "/packages") { pkgs = final; })
    ];
  };
}
