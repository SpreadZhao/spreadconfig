{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/nix-tools/scripts";
}
