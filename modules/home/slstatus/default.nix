{
  inputs,
  lib,
  pkgs,
  appEntries,
  host,
  theme_blue,
  theme_bright_red,
  theme_bright_yellow,
  theme_green,
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
    text = builtins.readFile ./scripts/slstatus/slstatus-query.sh;
  };
in
{
  imports = [ inputs.spreadless.homeManagerModules.slstatus ];
  spreadconfig.scriptFiles = appEntries "slstatus" "scripts";
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
