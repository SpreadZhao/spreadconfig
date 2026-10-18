{
  config,
  pkgs,
  fontFamilies,
  fontSizes,
  ...
}:

{
  gtk = {
    enable = true;
    colorScheme = "dark";
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 36;
    };
    font = {
      name = fontFamilies.sans;
      size = fontSizes.gtk;
    };
    gtk3 = {
      enable = true;
    };
    gtk4 = {
      enable = true;
      theme = config.gtk.theme;
    };
  };
}
