{ inputs, pkgs, ... }:

let
  hermesPackages = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    hermesPackages.default
    hermesPackages.desktop
  ];
}
