{ lib, pkgs, ... }:

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
      initialPassword = "${lib.strings.trim (builtins.readFile ../../secrets/passwd)}";
    };
    defaultUserShell = pkgs.zsh;
  };
}
