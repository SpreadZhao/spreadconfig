{
  appEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit".source = repoTree "lazygit" (appEntries "lazygit" "files");
}
