{
  config,
  lib,
  pkgs,
  inputs,
  fontFamilies,
  fontSizes,
  theme_background,
  theme_bright_dark,
  theme_bright_white,
  theme_blue,
  theme_bright_blue,
  ...
}:

let
  psst = config.services.gpg-agent.pinentry.package;
in
{
  home.packages = [ psst ];

  services.gpg-agent.pinentry = {
    package =
      lib.mkDefault
        inputs.personal-packages.packages.${pkgs.stdenv.hostPlatform.system}.psst-auth;
    program = "psst-pinentry";
  };

  xdg.configFile."psst/theme.kdl".text = ''
    window {
        font "${fontFamilies.sans}"
        size ${toString fontSizes.gtk}
        background "#${theme_background}"
        text "#${theme_bright_white}"
        border "#${theme_bright_dark}"
        radius 0

        title { size ${toString (fontSizes.gtk + 8)} }
        field {
            font "${fontFamilies.mono}"
            size ${toString fontSizes.gtk}
            radius 0
            focus { border "#${theme_blue}" }
        }
        confirm {
            background "#${theme_blue}"
            text "#${theme_bright_white}"
            radius 0
            hover { background "#${theme_bright_blue}" }
        }
        cancel { radius 0 }
    }
  '';

  systemd.user.services.psst-polkit-agent = {
    Unit = {
      Description = "Psst Polkit authentication agent";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "simple";
      ExecStart = "${psst}/bin/psst-polkit-agent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
