{ ... }:

{
  # Authorize this host to decrypt the shared secrets before rebuilding; see ./README.md.
  imports = [
    ./hardware-configuration.nix
    ./nixos
  ];
}
