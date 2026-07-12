{
  hostConfigSource,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.source-code-pro
    pkgs.swayimg
  ];

  xdg.configFile."swayimg".source = hostConfigSource "swayimg";
}
