{ appEntries, ... }:

{
  spreadconfig.scriptFiles = appEntries "git" "scripts";
}
