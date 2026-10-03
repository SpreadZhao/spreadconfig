{ pkgs, repoLink, ... }:

{
  xdg.dataFile = {
    "fcitx5/rime/rime-data".source = "${pkgs.rime-ice}/share/rime-data";
    "fcitx5/rime/default.custom.yaml".source = repoLink "modules/home/rime/files/default.custom.yaml";
    "fcitx5/rime/rime_ice.custom.yaml".source = repoLink "modules/home/rime/files/rime_ice.custom.yaml";
  };
}
