{ appEntries, ... }:

{
  spreadconfig.scriptFiles = appEntries "nix-tools" "scripts";
}
