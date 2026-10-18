{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];

  xdg.configFile."xdg-desktop-portal-termfilechooser".source =
    repoTree "xdg-desktop-portal-termfilechooser" (
      repoEntries "modules/home/xdg-desktop-portal-termfilechooser/files"
    );

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
    config.common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
  };
}
