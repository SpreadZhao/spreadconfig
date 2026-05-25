{ lib, ... }:

let
  entries = builtins.readDir ./.;
  moduleNames = lib.filter (
    name: name != "default.nix" && lib.hasSuffix ".nix" name && entries.${name} == "regular"
  ) (builtins.attrNames entries);
in
{
  imports = map (name: ./. + "/${name}") moduleNames;
}
