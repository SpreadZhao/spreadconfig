{
  inputs,
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
  colored = color: format: "^fg(${color})${format}^fg()";
  query = pkgs.writeShellApplication {
    name = "slstatus-query";
    runtimeInputs = [
      pkgs.gawk
      pkgs.wireplumber
    ];
    text = ''
      case "$1" in
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
in
{
  imports = [ inputs.spreadless.homeManagerModules.slstatus ];
  programs.slstatus = {
    interval = 9000;
    settings = {
      SLSTATUS_TEMP_COLOR_NORMAL = theme_green;
      SLSTATUS_TEMP_COLOR_WARNING = theme_yellow;
      SLSTATUS_TEMP_COLOR_CRITICAL = theme_bright_red;
    };
    components = lib.mkDefault (
      [
        {
          function = "cpu_perc";
          format = colored theme_bright_yellow "%s";
        }
        {
          function = "ram_perc";
          format = colored theme_purple "%s";
        }
        {
          function = "cpu_temp";
          format = "%s";
        }
        {
          function = "network_icon";
          format = colored theme_magenta "%s";
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
          function = "battery_icon";
          format = colored theme_red "%s";
          argument = host.profile.home.devices.battery;
        }
      ]
      ++ [
        {
          function = "datetime";
          format = colored theme_green "%s";
          argument = "%H:%M";
        }
      ]
    );
  };
}
