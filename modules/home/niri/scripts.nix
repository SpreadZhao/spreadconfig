{
  repoEntries,
  config,
  lib,
  ...
}:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/niri/scripts";

  home.sessionPath = lib.mkOrder 100 [ "$SCRIPT_HOME/niri/bin" ];

  xdg.userDirs.extraConfig = {
    SCREENSHOT = "${config.xdg.userDirs.pictures}/screenshot";
    SCREENRECORD = "${config.xdg.userDirs.videos}/screenrecord";
  };
}
