{ host, lib, ... }:

{
  networking = {
    networkmanager.enable = true;
    proxy = lib.mkIf host.profile.nixos.proxy.enable {
      default = "http://127.0.0.1:7897";
      noProxy = "127.0.0.1,localhost,.localdomain";
    };
  };
}
