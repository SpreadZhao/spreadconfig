{ ... }:

{
  imports = [
    ./vars.nix
    ./home-core.nix
    ./systemd.nix
    ./xdg.nix
    ./dconf.nix
    ./gtk.nix
    ./qt.nix
    ./programs
    ./nixvim.nix
    ./services
    ./fonts.nix
    ./i18n.nix
  ];
}
