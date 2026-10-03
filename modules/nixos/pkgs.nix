{ host, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = host.profile.nixos.rocmSupport;
  };
}
