{ pkgs, lib, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    commandLineArgs = [ "--password-store=basic" ];
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/chromium"
  ] (_: "chromium-browser.desktop");
}
