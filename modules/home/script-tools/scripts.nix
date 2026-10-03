{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/script-tools/scripts";
}
