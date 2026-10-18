{
  appEntries,
  repoTree,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [ pkgs.zathura ];

  xdg.configFile."zathura".source = repoTree "zathura" (appEntries "zathura" "files");

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/pdf"
  ] (_: "org.pwmt.zathura.desktop");

  xdg.mimeApps.associations.added = lib.genAttrs [
    "application/pdf"
  ] (_: "org.pwmt.zathura.desktop");
}
