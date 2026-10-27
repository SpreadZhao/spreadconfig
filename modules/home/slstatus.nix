{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  cfg = config.programs.slstatus;
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
