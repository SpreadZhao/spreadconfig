{ ... }:

{
  imports = [
    ./nix.nix
    ./hardware.nix
    ./boot.nix
    ./networking.nix
    ./time-console.nix
    ./filesystems.nix
    ./apps.nix
    ./services
    ./systemd.nix
    ./users.nix
    ./environment.nix
    ./security.nix
    ./fonts.nix
    ./state-version.nix
  ];
}
