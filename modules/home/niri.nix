{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.niri ];

  xdg.configFile."niri".source = hostConfigSource "niri";
}
