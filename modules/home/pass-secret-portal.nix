{ inputs, pkgs, ... }:

{
  imports = [ inputs.pass-secret-portal.homeManagerModules.default ];

  services.pass-secret-portal = {
    enable = true;
    package = inputs.pass-secret-portal.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
