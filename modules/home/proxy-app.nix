{ pkgs, pkgsPinned, ... }:

let
  # Keep the pre-update nixpkgs package: clash-verge-rev 2.4.7.
  clashVergeRev = pkgsPinned.old_a6c3b1b.clash-verge-rev;
in
{
  home.packages = [
    clashVergeRev
    # pkgs.flclash
    # pkgs.nekobox
  ];

  xdg.autostart.entries = [
    "${clashVergeRev}/share/applications/clash-verge.desktop"
    # "${pkgs.flclash}/share/applications/flclash.desktop"
    # "${pkgs.nekobox}/share/applications/nekobox.desktop"
  ];
}
