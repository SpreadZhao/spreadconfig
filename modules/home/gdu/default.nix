{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.gdu ];

  xdg.configFile."gdu".source = repoTree "gdu" (repoEntries "modules/home/gdu/files");
}
