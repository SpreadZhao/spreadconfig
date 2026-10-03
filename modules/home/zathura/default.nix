{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.zathura ];

  xdg.configFile."zathura".source = repoTree "zathura" (repoEntries "modules/home/zathura/files");
}
