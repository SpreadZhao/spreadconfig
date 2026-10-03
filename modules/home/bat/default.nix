{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.bat ];

  xdg.configFile."bat".source = repoTree "bat" (repoEntries "modules/home/bat/files");
}
