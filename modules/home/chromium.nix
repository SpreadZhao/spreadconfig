{ lib, pkgs, ... }:

let
  wrapperArgs = [
    "--add-flag"
    "--password-store=basic"
  ];
  chromiumPackage = pkgs.symlinkJoin {
    name = "chromium-basic-password-store";
    paths = [ pkgs.chromium ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/chromium ${lib.escapeShellArgs wrapperArgs}
    '';
  };
in
{
  home.packages = [ chromiumPackage ];
}
