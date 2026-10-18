{
  pkgs,
  repoLink,
  appSource,
  ...
}:

{
  xdg.dataFile = {
    "fcitx5/rime/rime-data".source = "${pkgs.rime-ice}/share/rime-data";
    "fcitx5/rime/default.custom.yaml".source = repoLink (appSource "rime" "files/default.custom.yaml");
    "fcitx5/rime/rime_ice.custom.yaml".source = repoLink (
      appSource "rime" "files/rime_ice.custom.yaml"
    );
  };
}
