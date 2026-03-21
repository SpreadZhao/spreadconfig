{
    config,
    pkgs,
    spreadconfigDir,
    ...
}:

{
    home.packages = [ pkgs.bat ];

    xdg.configFile."bat".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/bat";
}
