{ repoEntries, ... }:

{
  spreadconfig.scriptFiles = repoEntries "modules/home/agent-skill-profiles/scripts";
}
