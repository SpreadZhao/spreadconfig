{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.obsidian ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/obsidian"
  ] (_: "obsidian.desktop");
}
