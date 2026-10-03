{
  config,
  host,
  inputs,
  ...
}:

{
  imports = [
    inputs.textbridge.nixosModules.server
  ];

  services.textbridge.server = {
    enable = true;
    tokenFile = config.sops.secrets."textbridge-token".path;
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
}
