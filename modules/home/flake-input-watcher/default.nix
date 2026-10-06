{
  inputs,
  lib,
  projDir,
  ...
}:
{
  imports = [ inputs.flake-input-watcher.homeManagerModules.default ];
  services.flake-input-watcher = {
    enable = lib.mkDefault true;
    flakePath = lib.mkDefault projDir;
  };
}
