{ ... }:

{
  # Initialize the shared age identity before installation; see docs/sops.md.
  imports = [
    ./hardware-configuration.nix
    ./nixos
  ];
}
