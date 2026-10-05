{
  config,
  inputs,
  lib,
  pkgs,
  projDir,
  ...
}:
{
  imports = [ inputs.flake-input-watcher.homeManagerModules.default ];
  services.flake-input-watcher = {
    enable = lib.mkDefault true;
    flakePath = lib.mkDefault projDir;
  };
  # scripts/nix precedes package directories on PATH. Never resolve this command
  # by name from its compatibility entry, as that would recurse into itself.
  spreadconfig.scriptFiles."nix/flake-input-watcher" =
    pkgs.writeShellScript "flake-input-watcher-forward" ''
      exec "${config.services.flake-input-watcher.package}/bin/flake-input-watcher" "$@"
    '';
}
