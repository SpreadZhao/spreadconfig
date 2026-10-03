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
    description = "Script installation paths mapped to explicit sources supplied by their owning modules.";
  };

  config.home.file.${scriptsDir}.source =
    repoTree "spreadconfig-scripts" config.spreadconfig.scriptFiles;
}
