{ config, lib, ... }:

{
  services.darkman = {
    enable = true;
    settings = {
      usegeoclue = false;
      portal = true;
    };
  };

  systemd.user.services.darkman.Service.ExecStartPost =
    "${lib.getExe config.services.darkman.package} set dark";

  xdg.portal = {
    extraPortals = [ config.services.darkman.package ];
    config.common."org.freedesktop.impl.portal.Settings" = [ "darkman" ];
  };
}
