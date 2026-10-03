{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.source-code-pro
    pkgs.swayimg
  ];

  xdg.configFile."swayimg".source = repoTree "swayimg" (repoEntries "modules/home/swayimg/files");
}
