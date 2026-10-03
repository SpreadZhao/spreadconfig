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
}
