{
  config,
  pkgs,
  spreadconfigDir,
  ...
}:

{
  home.packages = [ pkgs.satty ];

  xdg.configFile."satty".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/satty";
}
