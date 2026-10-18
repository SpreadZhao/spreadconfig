{
  repoLink,
  appSource,
  ...
}:

{
  xdg.dataFile."codex-desktop/profiles/spreadzhao/codex/themes/spreadzhao.tmTheme" = {
    source = repoLink (appSource "codex" "files/themes/spreadzhao.tmTheme");
    force = true;
  };
}
