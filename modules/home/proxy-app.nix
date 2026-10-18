{
  host,
  lib,
  pkgs,
  ...
}:

lib.mkIf host.profile.nixos.proxy.enable {
  home.packages = [
    pkgs.clash-verge-rev
    # pkgs.flclash
  ];

  xdg.autostart.entries = [
    "${pkgs.clash-verge-rev}/share/applications/clash-verge.desktop"
    # "${pkgs.flclash}/share/applications/flclash.desktop"
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/clash" = "clash-verge.desktop";
}
