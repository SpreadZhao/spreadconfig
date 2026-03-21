{
    config,
    pkgs,
    spreadconfigDir,
    ...
}:

{
    home.packages = [ pkgs.niri ];

    xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/niri";
}
