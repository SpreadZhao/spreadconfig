{
  config,
  pkgs,
  spreadconfigDir,
  ...
}:

{
  home.packages = [ pkgs.starship ];

  xdg.configFile."starship".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/starship";
}
