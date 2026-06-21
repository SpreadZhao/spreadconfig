{ pkgs, ... }:

let
  chromiumPackage = pkgs.symlinkJoin {
    name = "chromium-basic-password-store";
    paths = [ pkgs.chromium ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/chromium \
        --add-flags "--password-store=basic"
    '';
  };
in
{
  home.packages = [ chromiumPackage ];
}
