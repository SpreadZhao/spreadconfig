{ pkgs, secretsDir, ... }:

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
      initialPassword = "${secretsDir}/passwd";
    };
    defaultUserShell = pkgs.zsh;
  };
}
