{
  appEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.bat ];

  xdg.configFile."bat".source = repoTree "bat" (appEntries "bat" "files");
}
