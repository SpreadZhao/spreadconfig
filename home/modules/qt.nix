{
    pkgs,
    fontFamilies,
    fontSizes,
    ...
}:

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
                fixed = "\"${fontFamilies.mono},${toString fontSizes.qt}\"";
                general = "\"${fontFamilies.sans},${toString fontSizes.qt}\"";
            };
        };
        qt6ctSettings = {
            Appearance = {
                standar_dialogs = "xdgdesktopportal";
            };
            Fonts = {
                fixed = "\"${fontFamilies.mono},${toString fontSizes.qt}\"";
                general = "\"${fontFamilies.sans},${toString fontSizes.qt}\"";
            };
        };
    };
}
