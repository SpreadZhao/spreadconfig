{ config, ... }:

{
  services.pass-secret-service = {
    enable = true;
    storePath = "${config.home.homeDirectory}/.password-store";
  };

  # A fresh host can activate before the private password store is cloned.
  systemd.user.services.pass-secret-service.Unit.ConditionPathExists =
    "${config.services.pass-secret-service.storePath}/.gpg-id";
}
