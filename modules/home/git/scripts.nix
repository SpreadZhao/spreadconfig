{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/git/scripts";
}
