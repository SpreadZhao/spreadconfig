{ config, pkgs, ... }:

let
    installedJDKs = with pkgs; [
        jdk25
        jdk21
        jdk17
        jdk11
        jdk8
    ];
    defaultJDK = builtins.elemAt installedJDKs 0;
    projDir = "${config.xdg.userDirs.extraConfig.WORKSPACE}/spreadconfig";
    scriptsDir = "${config.home.homeDirectory}/scripts";
    secretsDir = "${projDir}/secrets";
    spreadconfigDir = "${projDir}/spreadconfig";
    mochaBg = "0e1117";
    theme_tranparent = "00000000";
    theme_background = "000000";
    theme_red = "bc3f3c";
    theme_green = "6a9955";
    theme_yellow = "e6e6aa";
    theme_blue = "47a2ed";
    theme_purple = "3181a7";
    theme_magenta = "bc3f3c";
    theme_cyan = "47ccb1";
    theme_white = "d4d4d4";
    theme_bright_background = "3a3a3a";
    theme_bright_dark = "72737a";
    theme_bright_red = "ff0000";
    theme_bright_blue = "8cd7ff";
    theme_bright_white = "ffffff";
    theme_bright_yellow = "ffc66d";
    theme_radius = "0";
in
{
    _module.args = {
        inherit
            installedJDKs
            defaultJDK
            projDir
            scriptsDir
            secretsDir
            spreadconfigDir
            mochaBg
            theme_tranparent
            theme_background
            theme_red
            theme_green
            theme_yellow
            theme_blue
            theme_purple
            theme_magenta
            theme_cyan
            theme_white
            theme_bright_background
            theme_bright_dark
            theme_bright_red
            theme_bright_blue
            theme_bright_white
            theme_bright_yellow
            theme_radius
            ;
    };
}
