{
    config,
    pkgs,
    spreadconfigDir,
    ...
}:

{
    home.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

    xdg.configFile."xdg-desktop-portal-termfilechooser".source =
        config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/xdg-desktop-portal-termfilechooser";
}
