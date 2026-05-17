{ ... }:

{
  networking = {
    hostName = "thinkbook";
    networkmanager.enable = true;
    proxy = {
      default = "http://127.0.0.1:7897";
      noProxy = "127.0.0.1,localhost,.localdomain";
    };
  };
}
