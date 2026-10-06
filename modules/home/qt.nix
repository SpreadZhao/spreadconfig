{
  pkgs,
  fontFamilies,
  fontSizes,
  ...
}:

let
  qtctSettings = {
    Appearance = {
      standar_dialogs = "xdgdesktopportal";
    };
    Fonts = {
      fixed = "\"${fontFamilies.mono},${toString fontSizes.qt}\"";
      general = "\"${fontFamilies.sans},${toString fontSizes.qt}\"";
    };
  };
in
{
  qt = {
    enable = true;
    platformTheme.name = "xdgdesktopportal";
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;
  };
}
