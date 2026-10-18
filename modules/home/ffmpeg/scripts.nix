{ appEntries, ... }:

{
  spreadconfig.scriptFiles = appEntries "ffmpeg" "scripts";
}
