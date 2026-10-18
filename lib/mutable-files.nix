{
  lib,
  pkgs,
  repoRoot,
  projDir,
  hostName,
  mkOutOfStoreSymlink,
}:

let
  validRelative =
    path:
    builtins.isString path
    && path != ""
    && !(lib.hasPrefix "/" path)
    && lib.all (part: part != "" && part != "." && part != "..") (lib.splitString "/" path);

  checkedPath =
    relative:
    if validRelative relative then
      repoRoot + "/${relative}"
    else
      throw "Invalid repository-relative asset path: ${toString relative}";

  repoLink =
    relative:
    let
      source = checkedPath relative;
    in
    if !builtins.pathExists source then
      throw "Missing repository asset: ${relative}"
    else if !lib.pathIsRegularFile source then
      throw "Repository asset must be a regular file: ${relative}"
    else
      mkOutOfStoreSymlink "${projDir}/${relative}";

  repoEntries =
    relative:
    let
      source = checkedPath relative;
      walk =
        directory: prefix:
        lib.concatMap (
          name:
          let
            file = directory + "/${name}";
            target = if prefix == "" then name else "${prefix}/${name}";
          in
          if lib.pathIsDirectory file then
            walk file target
          else
            [ (lib.nameValuePair target (repoLink "${relative}/${target}")) ]
        ) (builtins.attrNames (builtins.readDir directory));
    in
    if !builtins.pathExists source || !lib.pathIsDirectory source then
      throw "Missing repository asset directory: ${relative}"
    else
      builtins.listToAttrs (walk source "");

  checkedEntries =
    name: entries:
    let
      targets = builtins.attrNames entries;
      invalid = lib.filter (target: !validRelative target) targets;
      conflicts = lib.filter (target: lib.any (other: lib.hasPrefix "${other}/" target) targets) targets;
    in
    if invalid != [ ] then
      throw "Invalid asset targets in ${name}: ${lib.concatStringsSep ", " invalid}"
    else if conflicts != [ ] then
      throw "Overlapping asset targets in ${name}: ${lib.concatStringsSep ", " conflicts}"
    else
      entries;

  # Return the selected repository path, also usable when reading build inputs.
  appSource =
    app: relative:
    let
      shared = "modules/home/${app}/${relative}";
      local = "hosts/${hostName}/home/${app}/${relative}";
      sharedPath = checkedPath shared;
      localPath = checkedPath local;
    in
    if !lib.pathIsRegularFile sharedPath then
      throw "Missing shared application file: ${shared}"
    else if builtins.pathExists localPath then
      if lib.pathIsRegularFile localPath then
        local
      else
        throw "Application override must be a file: ${local}"
    else
      shared;

  appEntries =
    app: relative:
    let
      shared = "modules/home/${app}/${relative}";
      local = "hosts/${hostName}/home/${app}/${relative}";
      localPath = checkedPath local;
    in
    checkedEntries "${app}/${relative}" (
      repoEntries shared // lib.optionalAttrs (builtins.pathExists localPath) (repoEntries local)
    );

  repoTree =
    name: entries:
    pkgs.linkFarm name (
      lib.mapAttrsToList (name: path: { inherit name path; }) (checkedEntries name entries)
    );
in
{
  inherit
    repoLink
    repoEntries
    repoTree
    appSource
    appEntries
    ;
}
