{ config, ... }:

{
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    enableZshIntegration = true;
    maxCacheTtl = 86400;
    pinentry = {
      package = config.programs.wayprompt.package;
      program = "pinentry-wayprompt";
    };
  };
}
