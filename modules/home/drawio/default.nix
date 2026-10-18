{ pkgs, lib, ... }:

let
  drawioMimePackage = pkgs.writeTextDir "share/mime/packages/drawio.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/vnd.jgraph.mxfile">
        <comment>draw.io diagram</comment>
        <glob pattern="*.drawio" weight="80"/>
        <glob pattern="*.drawio.xml" weight="80"/>
      </mime-type>
    </mime-info>
  '';
in
{
  home.packages = [
    pkgs.drawio
    drawioMimePackage
  ];

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
