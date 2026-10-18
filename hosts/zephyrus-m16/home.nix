args@{ pkgs, ... }:

# Keep this definition here to preserve package ordering.
(import ./home/nvtop.nix args)
// {
  imports = [
    ./home/gaomon-tablet.nix
    ./home/qutebrowser
    ./home/waybar.nix
  ];
}
