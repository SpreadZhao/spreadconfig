{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/ffmpeg/scripts";
}
