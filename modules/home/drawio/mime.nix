{ pkgs, ... }:

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
  home.packages = [ drawioMimePackage ];
}
