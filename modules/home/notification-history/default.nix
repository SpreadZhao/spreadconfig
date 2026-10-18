{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.notification-history.homeManagerModules.default ];
  services.notification-history = {
    enable = lib.mkDefault config.services.fnott.enable;
    package = lib.mkDefault (
      inputs.notification-history.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        neovim = config.programs.nixvim.build.package;
      }
    );
  };
}
