{
  config,
  host,
  lib,
  pkgs,
  repoEntries,
  repoTree,
  ...
}:

let
  profile = host.profile.home.waybar;
  hasBattery = host.capabilities.battery == true;
  hasTemperature = profile.temperaturePath != null;
  configDir = "${config.xdg.configHome}/waybar";
  # Waybar keeps the first definition of each field: this entry wins over its
  # native includes, while the shared files remain directly editable.
  entry = {
    include = [
      "${configDir}/common.jsonc"
    ]
    ++ lib.optional hasBattery "${configDir}/battery.jsonc"
    ++ lib.optional hasTemperature "${configDir}/temperature.jsonc";
    height = profile.height;
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
    temperature."hwmon-path-abs" = profile.temperaturePath;
  };
in
{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.waybar ];

  xdg.configFile."waybar".source = repoTree "waybar-config" (
    repoEntries "modules/home/waybar/files"
    // {
      "config.jsonc" = pkgs.writeText "waybar-config.jsonc" (builtins.toJSON entry);
      "style.css" = pkgs.writeText "waybar-style.css" ''
        @import "common.css";
        * { font-size: ${toString profile.fontSize}px; }
      '';
    }
  );
  xdg.configFile."systemd/user/waybar.service".source =
    "${pkgs.waybar}/share/systemd/user/waybar.service";
}
