{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.wemeet ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/wemeet"
  ] (_: "wemeetapp.desktop");
}
