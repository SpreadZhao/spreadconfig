{ ... }:

{
  imports = [
    ./nix.nix
    ./hardware.nix
    ./boot.nix
    ./networking.nix
    ./time-console.nix
    ./filesystems.nix
    ./programs
    ./services
    ./systemd.nix
    ./users.nix
    ./environment.nix
    ./security.nix
    ./fonts.nix
    ./state-version.nix
  ];
}
