{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    pinentry = {
      package = pkgs.wayprompt;
      program = "pinentry-wayprompt";
    };
  };
}
