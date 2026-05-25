{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.bat ];

  xdg.configFile."bat".source = hostConfigSource "bat";
}
