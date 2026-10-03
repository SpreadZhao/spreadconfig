{
  repoLink,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.codex ];

  home.file.".codex/themes/spreadzhao.tmTheme".source =
    repoLink "modules/home/codex/files/themes/spreadzhao.tmTheme";
}
