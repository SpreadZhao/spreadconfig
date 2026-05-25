{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.satty ];

  xdg.configFile."satty".source = hostConfigSource "satty";
}
