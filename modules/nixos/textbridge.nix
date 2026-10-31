{
  config,
  host,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.textbridge.nixosModules.server
  ];

  services.textbridge.server = {
    enable = true;
    listenHost = "0.0.0.0";
    port = 17321;
    discovery.port = 17322;
  };

  services.textbridge.bluetooth = {
    # The TextBridge module itself enables hardware.bluetooth. Reading that
    # option here would make the two enable flags depend on each other.
    enable =
      host.profile.nixos.bluetooth.enable
      && host.capabilities.bluetooth != false
      && host.profile.nixos.textbridge.bluetooth.enable;
    channel = 22;
  };

  # Restrict these shared user units to spreadzhao, who owns the Fcitx socket.
  systemd.user.services = {
    textbridge-server.unitConfig.ConditionUser = "spreadzhao";
    textbridge-bluetooth-server = lib.mkIf config.services.textbridge.bluetooth.enable {
      unitConfig.ConditionUser = "spreadzhao";
    };
  };
}
