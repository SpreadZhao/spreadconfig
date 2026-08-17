{ inputs, pkgs, ... }:

let
  antigravityPackages = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # home.packages = [
  #   antigravityPackages.google-antigravity
  #   antigravityPackages.google-antigravity-ide
  #   antigravityPackages.google-antigravity-cli
  # ];
}
