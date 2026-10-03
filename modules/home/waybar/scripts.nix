{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/waybar/scripts";
}
