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
    temperaturePath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
  };
}
