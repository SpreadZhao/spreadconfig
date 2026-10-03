{ pkgs, ... }:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.pass ];
}
