{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.starship ];

  xdg.configFile."starship".source = repoTree "starship" (repoEntries "modules/home/starship/files");
}
