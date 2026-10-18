{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.drawio ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "application/vnd.jgraph.mxfile"
    "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
    "application/vnd.ms-visio.drawing.main+xml"
    "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
    "application/vnd.ms-visio.stencil.main+xml"
    "application/vnd.ms-visio.template.macroEnabled.main+xml"
    "application/vnd.ms-visio.template.main+xml"
    "application/vnd.visio"
  ] (_: "drawio.desktop");
}
