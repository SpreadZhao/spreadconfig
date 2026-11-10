{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system}.bili23-downloader
  ];
}
