{
  repoLink,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.codex ];

  xdg.dataFile."codex-desktop/profiles/spreadzhao/codex/themes/spreadzhao.tmTheme" = {
    source = repoLink "modules/home/codex/files/themes/spreadzhao.tmTheme";
    force = true;
  };
}
