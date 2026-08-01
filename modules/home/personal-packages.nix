{ inputs, pkgs, ... }:

let
  personalPackages = inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    personalPackages.bili23-downloader
    personalPackages.cc-connect
    personalPackages.docsify-cli
    personalPackages.zcode
  ];
}
