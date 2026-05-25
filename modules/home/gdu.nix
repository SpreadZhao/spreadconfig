{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.gdu ];

  xdg.configFile."gdu".source = hostConfigSource "gdu";
}
