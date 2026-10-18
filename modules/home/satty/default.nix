{
  appEntries,
  repoTree,
  pkgs,
  config,
  ...
}:

{
  home.packages = [
    pkgs.satty
  ];

  xdg.configFile."satty".source = repoTree "satty" (appEntries "satty" "files");

  xdg.userDirs.extraConfig.SATTY = "${config.xdg.userDirs.pictures}/satty";
}
