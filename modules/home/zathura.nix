{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.zathura ];

  xdg.configFile."zathura".source = hostConfigSource "zathura";
}
