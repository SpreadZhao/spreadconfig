{ ... }:

{
  imports = [
    ./boot.nix
    ./environment.nix
    ./filesystems.nix
    ./fonts.nix
    ./networking.nix
    ./nix.nix
    ./pkgs.nix
    ./security.nix
    ./secrets.nix
    ./state-version.nix
    ./systemd.nix
    ./time-console.nix
    ./users.nix
  ];
}
