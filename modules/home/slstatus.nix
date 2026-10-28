{
  config,
  lib,
  pkgs,
  host,
  theme_blue,
  theme_bright_red,
  theme_bright_yellow,
  theme_green,
  theme_magenta,
  theme_purple,
  theme_red,
  theme_yellow,
  ...
}:
let
  cfg = config.programs.slstatus;
  colored = color: format: "^fg(${color})${format}^fg()";
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
            awk -v normal="${theme_green}" -v warning="${theme_yellow}" -v critical="${theme_bright_red}" '
              NF != 1 || $1 !~ /^-?[0-9]+$/ { printf "-"; exit }
              {
                temperature = int($1 / 1000 + ($1 >= 0 ? 0.5 : -0.5))
                color = temperature >= 80 ? critical : temperature >= 60 ? warning : normal
                split("    ", icons, " ")
                level = int(temperature / 20) + 1
                if (level < 1) level = 1
                if (level > 5) level = 5
                printf "^fg(%s)%d%s^fg()", color, temperature, icons[level]
              }
            ' "$sensor/temp1_input"
            exit 0
            ;;
          esac
        done
        printf -- '-'
        ;;
      network)
        interface=$(ip -o route show default | awk 'NR == 1 { for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }' || true)
        if [[ -z "$interface" ]]; then
          interface=$(ip -o -6 route show default | awk 'NR == 1 { for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }' || true)
        fi
        if [[ -z "$interface" ]]; then
          printf '󰯡'
        elif [[ -d "/sys/class/net/$interface/wireless" ]]; then
          printf ''
        else
          printf '󰈀'
        fi
        ;;
      sink|source)
        if [[ "$1" == sink ]]; then node=@DEFAULT_AUDIO_SINK@; else node=@DEFAULT_AUDIO_SOURCE@; fi
        if ! volume=$(wpctl get-volume "$node" 2>/dev/null); then
          printf -- '-'
          exit 0
        fi
        if [[ "$1" == source ]]; then
          icon='󰍬'
          muted_icon='󰍭'
        else
          info=$(wpctl inspect "$node" 2>/dev/null || true)
          case "''${info,,}" in
          *blue*) icon='󰂯'; muted_icon='󰂲' ;;
          *headphone*|*headset*) icon=''; muted_icon='󰟎' ;;
          *) icon='󰕾'; muted_icon='󰖁' ;;
          esac
        fi
        if [[ "$volume" == *'[MUTED]'* ]]; then icon=$muted_icon; fi
        awk -v icon="$icon" '
          $1 == "Volume:" && $2 ~ /^[0-9]+([.][0-9]+)?$/ {
            printf "%.0f%s", $2 * 100, icon
            found = 1
            exit
          }
          END { if (!found) printf "-" }
        ' <<< "$volume"
        ;;
      esac
    '';
  };
  conf = ''
    const unsigned int interval = ${toString cfg.interval};
    static const char unknown_str[] = "-";
    #define MAXLEN 1024
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
          format = colored theme_bright_yellow "%s";
        }
        {
          function = "ram_perc";
          format = colored theme_purple "%s";
        }
        {
          function = "run_command";
          format = "%s";
          argument = "${lib.getExe query} temperature";
        }
        {
          function = "run_command";
          format = colored theme_magenta "%s";
          argument = "${lib.getExe query} network";
        }
        {
          function = "run_command";
          format = colored theme_blue "%s";
          argument = "${lib.getExe query} sink";
        }
        {
          function = "run_command";
          format = colored theme_blue "%s";
          argument = "${lib.getExe query} source";
        }
      ]
      ++ lib.optionals (host.capabilities.battery == true) [
        {
          function = "battery_perc";
          format = colored theme_red "%s󰁹";
          argument = host.profile.home.devices.battery;
        }
      ]
      ++ [
        {
          function = "datetime";
          format = colored theme_green "%s";
          argument = "%H:%M";
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
