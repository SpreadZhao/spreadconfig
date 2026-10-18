{ config, ... }:

{
  users = {
    users.spreadzhao = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Allow sudo.
      ];
      hashedPasswordFile = config.sops.secrets."spreadzhao-password-hash".path;
    };
  };
}
