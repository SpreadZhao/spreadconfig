{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.programs.codexDesktopLinux;
  browser = import ./browser.nix {
    inherit inputs lib pkgs;
    inherit (cfg) linuxFeatures;
    enableComputerUseUi = cfg.computerUseUi.enable;
    enableRemoteMobileControl = cfg.remoteMobileControl.enable;
    proxy = osConfig.networking.proxy;
  };
  profiles = import ./profiles.nix {
    inherit config lib pkgs;
    inherit (browser) environment;
    desktopPackage = browser.package;
  };
in
{
  programs.codexDesktopLinux = {
    enable = true;
    package = profiles.package;
    linuxFeatures = [
      "frameless-titlebar"
      "remote-control-ui"
      "remote-mobile-control"
    ]
    ++ lib.optional browser.hasProxy "browser-proxy";
  };

  xdg.dataFile = profiles.desktopFiles;

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/codex"
    "x-scheme-handler/codex-browser-sidebar"
  ] (_: "codex-desktop.desktop");
}
