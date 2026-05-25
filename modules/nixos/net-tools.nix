{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.net-tools ];
}
