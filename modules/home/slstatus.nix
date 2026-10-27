{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  cfg = config.programs.slstatus;
  query = pkgs.writeShellApplication {
    name = "slstatus-query";
    runtimeInputs = [
      pkgs.gawk
      pkgs.iproute2
      pkgs.wireplumber
    ];
    text = ''
      case "$1" in
      temperature)
        for sensor in /sys/class/hwmon/hwmon*; do
          [[ -r "$sensor/name" && -r "$sensor/temp1_input" ]] || continue
          read -r name < "$sensor/name"
          case "$name" in
          coretemp|k10temp|zenpower|cpu_thermal)
            awk '{ printf "%.0f°C", $1 / 1000 }' "$sensor/temp1_input"
            exit 0
            ;;
          esac
        done
        printf -- '-'
        ;;
      network)
        interface=$(ip -o route show default | awk 'NR == 1 { for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
        if [[ -z "$interface" ]]; then
          interface=$(ip -o -6 route show default | awk 'NR == 1 { for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
        fi
        printf '%s' "''${interface:--}"
        ;;
      sink|source)
        if [[ "$1" == sink ]]; then node=@DEFAULT_AUDIO_SINK@; else node=@DEFAULT_AUDIO_SOURCE@; fi
        if volume=$(wpctl get-volume "$node" 2>/dev/null); then
          awk '{ printf "%.0f%%", $2 * 100; if ($0 ~ /MUTED/) printf " M" }' <<< "$volume"
        else
          printf -- '-'
        fi
        ;;
      esac
    '';
  };
  conf = ''
    const unsigned int interval = ${toString cfg.interval};
    static const char unknown_str[] = "-";
    #define MAXLEN 240
    static const struct arg args[] = {
      ${lib.concatMapStringsSep "\n" (
        component:
        "{ ${component.function}, ${builtins.toJSON component.format}, ${
          if component.argument == null then "NULL" else builtins.toJSON component.argument
        } },"
      ) cfg.components}
    };
  '';
in
{
  options.programs.slstatus = {
    enable = lib.mkEnableOption "slstatus";
    package = lib.mkPackageOption pkgs "slstatus" { };
    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2000;
      description = "Refresh interval in milliseconds.";
    };
    components = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            function = lib.mkOption {
              type = lib.types.strMatching "[a-zA-Z_][a-zA-Z0-9_]*";
              description = "slstatus component function, such as `cpu_perc` or `datetime`.";
            };
            format = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Printf format containing one `%s` placeholder.";
            };
            argument = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Component argument; `null` supplies the C `NULL` argument.";
            };
          };
        }
      );
      default = [
        {
          function = "cpu_perc";
          format = "CPU %s%% | ";
        }
        {
          function = "ram_perc";
          format = "RAM %s%% | ";
        }
        {
          function = "run_command";
          format = "TEMP %s | ";
          argument = "${lib.getExe query} temperature";
        }
        {
          function = "run_command";
          format = "NET %s | ";
          argument = "${lib.getExe query} network";
        }
        {
          function = "run_command";
          format = "VOL %s | ";
          argument = "${lib.getExe query} sink";
        }
        {
          function = "run_command";
          format = "MIC %s | ";
          argument = "${lib.getExe query} source";
        }
      ]
      ++ lib.optionals (host.capabilities.battery == true) [
        {
          function = "battery_perc";
          format = "BAT %s%% | ";
          argument = host.profile.home.devices.battery;
        }
      ]
      ++ [
        {
          function = "datetime";
          format = "%s";
          argument = "%F %T";
        }
      ];
      description = "Status components in display order.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.package.override { inherit conf; };
      description = "slstatus package with the configured components and interval.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.components != [ ];
        message = "slstatus requires at least one component.";
      }
    ];
    home.packages = [ cfg.finalPackage ];
  };
}
