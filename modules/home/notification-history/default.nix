{
  config,
  inputs,
  lib,
  pkgs,
  fzfPopupPackage,
  ...
}:
{
  imports = [ inputs.notification-history.homeManagerModules.default ];
  services.notification-history = {
    enable = lib.mkDefault config.services.fnott.enable;
    package = lib.mkDefault (
      inputs.notification-history.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        fzf-popup = fzfPopupPackage;
        neovim = config.programs.nixvim.build.package;
      }
    );
  };
}
