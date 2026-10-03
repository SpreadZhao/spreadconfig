{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/pass/scripts";
}
