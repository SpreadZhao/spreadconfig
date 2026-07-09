{
  hostConfigSource,
  inputs,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = false;
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
        fcitx5-mozc
        inputs.textbridge.packages.${system}.fcitx5-textbridge
      ];
    };
  };

  xdg.configFile."fcitx5" = {
    source = hostConfigSource "fcitx5";
    recursive = true;
    force = true;
  };
}
