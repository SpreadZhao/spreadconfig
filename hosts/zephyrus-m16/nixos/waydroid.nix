{ pkgs, ... }:

{
  networking.nftables.enable = true;

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
}
