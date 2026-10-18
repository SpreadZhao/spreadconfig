{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.element-desktop ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/element"
    "x-scheme-handler/io.element.desktop"
  ] (_: "element-desktop.desktop");
}
