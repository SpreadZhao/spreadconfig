{
  config,
  pkgs,
  spreadconfigDir,
  ...
}:

{
  home.packages = [ pkgs.zathura ];

  xdg.configFile."zathura".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/zathura";
}
