{ lib, ... }:

let
  entries = builtins.readDir ./.;
in
{
  imports = map (name: ./. + "/${name}") (
    lib.filter (
      name: name != "default.nix" && lib.hasSuffix ".nix" name && entries.${name} == "regular"
    ) (builtins.attrNames entries)
  );
}
