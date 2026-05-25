{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.waybar ];

  xdg.configFile."waybar".source = hostConfigSource "waybar";
  xdg.configFile."systemd/user/waybar.service".source =
    "${pkgs.waybar}/share/systemd/user/waybar.service";
}
