{ pkgs, ... }:

{
    qt = {
        enable = true;
        platformTheme.name = "xdgdesktopportal";
        style = {
            package = pkgs.adwaita-qt;
            name = "adwaita-dark";
        };
        qt5ctSettings = {
            Appearance = {
                standar_dialogs = "xdgdesktopportal";
            };
            Fonts = {
                fixed = "\"IBM Plex Mono,16\"";
                general = "\"IBM Plex Sans,16\"";
            };
        };
        qt6ctSettings = {
            Appearance = {
                standar_dialogs = "xdgdesktopportal";
            };
            Fonts = {
                fixed = "\"IBM Plex Mono,16\"";
                general = "\"IBM Plex Sans,16\"";
            };
        };
    };
}
