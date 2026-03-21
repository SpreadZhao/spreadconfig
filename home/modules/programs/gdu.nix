{
    config,
    pkgs,
    spreadconfigDir,
    ...
}:

{
    home.packages = [ pkgs.gdu ];

    xdg.configFile."gdu".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/gdu";
}
