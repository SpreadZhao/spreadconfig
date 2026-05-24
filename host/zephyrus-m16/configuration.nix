{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/modules
    ./nixos
  ];
}
