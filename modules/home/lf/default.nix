{
  repoEntries,
  repoTree,
  pkgs,
  ...
}:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.lf ];

  xdg.configFile."lf".source = repoTree "lf" (repoEntries "modules/home/lf/files");
}
