{
  config,
  host,
  lib,
  pkgs,
  appEntries,
  repoTree,
  ...
}:
{
  height ? 30,
  fontSize ? 20,
  temperaturePath ? null,
}:

let
  hasBattery = host.capabilities.battery == true;
  hasTemperature = temperaturePath != null;
  configDir = "${config.xdg.configHome}/waybar";
  # Waybar keeps the first definition of each field: this entry wins over its
  # native includes, while the shared files remain directly editable.
  entry = {
    include = [
      "${configDir}/common.jsonc"
    ]
    ++ lib.optional hasBattery "${configDir}/battery.jsonc"
    ++ lib.optional hasTemperature "${configDir}/temperature.jsonc";
    height = height;
  }
  // lib.optionalAttrs hasBattery {
    "modules-right" = [
      "group/usage"
      "network"
      "group/audio"
      "group/power"
      "custom/time"
      "tray"
    ];
  }
  // lib.optionalAttrs hasTemperature {
    "group/usage".modules = [
      "cpu"
      "memory"
      "temperature"
    ];
    temperature."hwmon-path-abs" = temperaturePath;
  };
in
repoTree "waybar-config" (
  appEntries "waybar" "files"
  // {
    "config.jsonc" = pkgs.writeText "waybar-config.jsonc" (builtins.toJSON entry);
    "style.css" = pkgs.writeText "waybar-style.css" ''
      @import "common.css";
      * { font-size: ${toString fontSize}px; }
    '';
  }
)
