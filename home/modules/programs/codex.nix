{
  config,
  spreadconfigDir,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.codex ];

  home.file.".codex/themes/spreadzhao.tmTheme".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/codex/themes/spreadzhao.tmTheme";
}
