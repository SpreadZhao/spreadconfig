{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/zsh/scripts";
}
