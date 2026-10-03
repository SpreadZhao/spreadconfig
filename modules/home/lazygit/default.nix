{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit".source = repoTree "lazygit" (repoEntries "modules/home/lazygit/files");
}
