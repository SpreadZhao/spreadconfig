{ config, inputs, ... }:

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
    enable = true;
    channel = 22;
  };
}
