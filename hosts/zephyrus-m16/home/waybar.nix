args@{
  config,
  host,
  lib,
  pkgs,
  appEntries,
  repoTree,
  ...
}:

{
  xdg.configFile."waybar".source = (import ../../../modules/home/waybar/config.nix args) {
    height = 25;
    fontSize = 16;
    temperaturePath = "/sys/devices/platform/coretemp.0/hwmon";
  };
}
