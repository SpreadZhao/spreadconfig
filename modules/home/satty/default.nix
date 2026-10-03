{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.satty
  ];

  xdg.configFile."satty".source = repoTree "satty" (repoEntries "modules/home/satty/files");
}
