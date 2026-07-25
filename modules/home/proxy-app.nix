{ pkgs, ... }:

{
  home.packages = [
    pkgs.clash-verge-rev
    # pkgs.flclash
  ];

  xdg.autostart.entries = [
    "${pkgs.clash-verge-rev}/share/applications/clash-verge.desktop"
    # "${pkgs.flclash}/share/applications/flclash.desktop"
  ];
}
