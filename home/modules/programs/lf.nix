{
    config,
    pkgs,
    spreadconfigDir,
    ...
}:

{
    home.packages = [ pkgs.lf ];

    xdg.configFile."lf".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/lf";
}
