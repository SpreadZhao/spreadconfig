{ pkgs, ... }:

{
  spreadconfig.apps.niri.hostConfig = "hosts/zephyrus-m16/home/niri/host.kdl";
  spreadconfig.apps.qutebrowser.hostConfig = "hosts/zephyrus-m16/home/qutebrowser/host.py";
  imports = [ ./home/gaomon-tablet.nix ];

  home.packages = [ pkgs.nvtopPackages.full ];
}
