{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

  xdg.configFile."xdg-desktop-portal-termfilechooser".source =
    hostConfigSource "xdg-desktop-portal-termfilechooser";
}
