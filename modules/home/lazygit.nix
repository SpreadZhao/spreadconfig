{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit".source = hostConfigSource "lazygit";
}
