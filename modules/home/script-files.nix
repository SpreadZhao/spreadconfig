{
  config,
  lib,
  repoTree,
  scriptsDir,
  ...
}:

{
  options.spreadconfig.scriptFiles = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    description = "Installed script paths mapped to application-owned sources.";
  };

  config.home.sessionVariables.SCRIPT_HOME = scriptsDir;

  config.home.file.${scriptsDir}.source =
    repoTree "spreadconfig-scripts" config.spreadconfig.scriptFiles;
}
