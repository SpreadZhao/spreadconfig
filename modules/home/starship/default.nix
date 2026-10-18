{
  appEntries,
  repoTree,
  pkgs,
  config,
  ...
}:

{
  home.packages = [ pkgs.starship ];

  xdg.configFile."starship".source = repoTree "starship" (appEntries "starship" "files");

  home.sessionVariables.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
}
