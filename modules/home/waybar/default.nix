args@{
  config,
  host,
  lib,
  pkgs,
  appEntries,
  repoTree,
  ...
}:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.waybar ];
  xdg.configFile."waybar".source = lib.mkDefault ((import ./config.nix args) { });
  xdg.configFile."systemd/user/waybar.service".source =
    "${pkgs.waybar}/share/systemd/user/waybar.service";
}
