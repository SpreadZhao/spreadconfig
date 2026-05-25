{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.lf ];

  xdg.configFile."lf".source = hostConfigSource "lf";
}
