{ pkgs, ... }:

{
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = pkgs.codex;
    linuxFeatures = [
      "frameless-titlebar"
      "remote-control-ui"
      "remote-mobile-control"
      "shared-app-server-socket"
    ];
  };

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
}
