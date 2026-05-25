{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.starship ];

  xdg.configFile."starship".source = hostConfigSource "starship";
}
