{
  config,
  pkgs,
  spreadconfigDir,
  ...
}:

{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/lazygit";
}
