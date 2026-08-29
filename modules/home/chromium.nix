{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    commandLineArgs = [ "--password-store=basic" ];
  };
}
