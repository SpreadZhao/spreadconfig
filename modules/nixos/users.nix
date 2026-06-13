{ config, pkgs, ... }:

{
  users = {
    users.spreadzhao = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        # "ydotool"
      ];
      # packages = with pkgs; [
      #   tree
      # ];
      # shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."spreadzhao-password-hash".path;
    };
    defaultUserShell = pkgs.zsh;
  };
}
