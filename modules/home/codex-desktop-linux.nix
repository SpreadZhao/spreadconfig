{ ... }:

{
  programs.codexDesktopLinux = {
    enable = true;
    linuxFeatures = [
      "frameless-titlebar"
      "remote-control-ui"
      "remote-mobile-control"
      "shared-app-server-socket"
    ];
  };

  xdg.configFile."codex-desktop/electron-flags.conf" = {
    force = true;
    text = ''
      # Managed by Home Manager.
      --password-store=basic
    '';
  };

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
}
