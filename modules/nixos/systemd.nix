{ ... }:

{
  systemd.services = {
    nix-daemon.serviceConfig.Slice = "-.slice";
  };
}
