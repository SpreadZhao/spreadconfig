{
  host,
  lib,
  pkgs,
  ...
}:

lib.mkIf host.profile.nixos.proxy.enable {
  home.packages = [
    pkgs.clash-verge-rev
  ];

  xdg.autostart.entries = [
    "${pkgs.clash-verge-rev}/share/applications/clash-verge.desktop"
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/clash" = "clash-verge.desktop";
}
