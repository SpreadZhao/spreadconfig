{
  repoEntries,
  repoTree,
  pkgs,
  config,
  ...
}:

{
  home.packages = [ pkgs.starship ];

  xdg.configFile."starship".source = repoTree "starship" (repoEntries "modules/home/starship/files");

  home.sessionVariables.STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
}
