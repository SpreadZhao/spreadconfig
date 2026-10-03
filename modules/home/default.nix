{ lib, ... }:

let
  entries = builtins.readDir ./.;
  fileNames = lib.filter (
    name: name != "default.nix" && lib.hasSuffix ".nix" name && entries.${name} == "regular"
  ) (builtins.attrNames entries);
  directoryNames = lib.filter (
    name: entries.${name} == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
  ) (builtins.attrNames entries);
  duplicates = lib.filter (name: builtins.elem "${name}.nix" fileNames) directoryNames;
  # Keep the original alphabetical module order when app.nix becomes app/.
  modulesByName = builtins.listToAttrs (
    map (name: lib.nameValuePair name (./. + "/${name}")) fileNames
    ++ map (name: lib.nameValuePair "${name}.nix" (./. + "/${name}")) directoryNames
  );
in
assert lib.assertMsg (
  duplicates == [ ]
) "Duplicate Home Manager file/directory modules: ${lib.concatStringsSep ", " duplicates}";
{
  imports = builtins.attrValues modulesByName;
}
