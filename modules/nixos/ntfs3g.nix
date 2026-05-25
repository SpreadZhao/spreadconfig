{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ntfs3g ];
}
