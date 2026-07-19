{ ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = true;
  };
}
