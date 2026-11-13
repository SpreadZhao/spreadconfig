{ host, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    rocmSupport = host.profile.nixos.rocmSupport;
    # QtWebEngine still accepts the compromised eMudhra intermediates.
    permittedInsecurePackages = [ "qutebrowser-3.7.0" ];
    # Home Manager's i18n.inputMethod still builds gtk2-immodule.cache.
    problems.handlers."gtk+".broken = "ignore";
  };
}
