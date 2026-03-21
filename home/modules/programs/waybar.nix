{
  config,
  spreadconfigDir,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.waybar ];

  xdg.configFile."waybar".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/waybar";
  xdg.configFile."systemd/user/waybar.service".source =
    "${pkgs.waybar}/share/systemd/user/waybar.service";
}
