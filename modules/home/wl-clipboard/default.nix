{ pkgs, ... }:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.wl-clipboard ];
}
