{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    enableZshIntegration = true;
    maxCacheTtl = 86400;
    pinentry = {
      package = pkgs.wayprompt;
      program = "pinentry-wayprompt";
    };
  };
}
