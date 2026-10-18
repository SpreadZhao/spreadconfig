{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.telegram-desktop ];

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/tg"
    "x-scheme-handler/tonsite"
  ] (_: "org.telegram.desktop.desktop");

  xdg.mimeApps.associations.added = lib.genAttrs [
    "x-scheme-handler/tg"
    "x-scheme-handler/tonsite"
  ] (_: "org.telegram.desktop.desktop");
}
