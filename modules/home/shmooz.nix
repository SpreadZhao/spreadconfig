{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system}.shmooz ];
}
