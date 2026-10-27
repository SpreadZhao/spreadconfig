{
  appEntries,
  lib,
  ...
}:

{
  spreadconfig.scriptFiles = appEntries "dwl" "scripts";

  home.sessionPath = lib.mkOrder 100 [ "$SCRIPT_HOME/dwl/bin" ];
}
