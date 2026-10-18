{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.rnote ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/rnote"
  ] (_: "com.github.flxzt.rnote.desktop");
}
