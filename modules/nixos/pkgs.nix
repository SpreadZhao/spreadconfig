{ host, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = host.profile.nixos.rocmSupport;
    # Home Manager's i18n.inputMethod still builds gtk2-immodule.cache.
    problems.handlers."gtk+".broken = "ignore";
  };
}
