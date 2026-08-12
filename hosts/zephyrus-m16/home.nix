{ pkgs, ... }:

{
  imports = [ ./home/gaomon-tablet.nix ];

  home.packages = [ pkgs.nvtopPackages.full ];
}
