{
  repoEntries,
  repoTree,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [ pkgs.zathura ];

  xdg.configFile."zathura".source = repoTree "zathura" (repoEntries "modules/home/zathura/files");

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/pdf"
  ] (_: "org.pwmt.zathura.desktop");

  xdg.mimeApps.associations.added = lib.genAttrs [
    "application/pdf"
  ] (_: "org.pwmt.zathura.desktop");
}
