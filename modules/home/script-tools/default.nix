{
  lib,
  pkgs,
  scriptsDir,
  ...
}:

{
  imports = [ ./scripts.nix ];

  # PATH groups keep their established precedence: niri, shared tools, Nix.
  home.sessionPath = lib.mkOrder 200 [ "$SCRIPT_HOME/util/bin" ];

  xdg.desktopEntries.change_audio = {
    name = "Change Audio Device";
    type = "Application";
    exec = "${pkgs.python3}/bin/python3 ${scriptsDir}/util/change_audio.py";
    icon = "";
    categories = [
      "AudioVideo"
      "Utility"
    ];
  };
}
