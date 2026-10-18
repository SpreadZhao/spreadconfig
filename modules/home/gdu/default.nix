{
  appEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.gdu ];

  xdg.configFile."gdu".source = repoTree "gdu" (appEntries "gdu" "files");
}
