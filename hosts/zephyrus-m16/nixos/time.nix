{ lib, ... }:

let
  timeServers = [
    "ntp.aliyun.com"
    "time1.cloud.tencent.com"
    "ntp.ntsc.ac.cn"
  ];
in
{
  networking.timeServers = lib.mkForce timeServers;

  services.timesyncd = {
    servers = timeServers;
    fallbackServers = lib.mkForce timeServers;
  };
}
