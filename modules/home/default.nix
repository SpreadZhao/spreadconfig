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
in
assert lib.assertMsg (
  duplicates == [ ]
) "Duplicate Home Manager file/directory modules: ${lib.concatStringsSep ", " duplicates}";
{
  # Sort file and directory modules together to preserve import order.
  imports = builtins.attrValues (
    builtins.listToAttrs (
      map (name: lib.nameValuePair name (./. + "/${name}")) fileNames
      ++ map (name: lib.nameValuePair "${name}.nix" (./. + "/${name}")) directoryNames
    )
  );
}
