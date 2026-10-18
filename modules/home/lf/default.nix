{
  repoEntries,
  repoTree,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.lf ];

  xdg.configFile."lf".source = repoTree "lf" (repoEntries "modules/home/lf/files");

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "inode/directory"
  ] (_: "lf.desktop");
}
