{ pkgs, ... }:

{
  systemd.services = {
    nix-daemon.serviceConfig.Slice = "-.slice";
    net-usage = {
      path = with pkgs; [
        bash
        nethogs
      ];
      description = "Per Boot Network Usage Logger";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "/home/spreadzhao/scripts/util/net-usage-logger.sh";
        Restart = "always";
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
