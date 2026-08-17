{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.codex ];

  home.file.".codex/themes/spreadzhao.tmTheme".source =
    hostConfigSource "codex/themes/spreadzhao.tmTheme";
}
