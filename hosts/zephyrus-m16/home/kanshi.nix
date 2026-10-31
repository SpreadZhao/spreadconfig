{ lib, ... }:
let
  displays = {
    "HDMI-A-1" = {
      mode = "3440x1440@100Hz";
      scale = 1.25;
      position = "0,0";
    };
    "DP-1" = {
      scale = 1.1;
      position = "2752,180";
    };
    "eDP-1" = {
      scale = 2.0;
      position = "4288,500";
    };
  };
  connectedSets = [
    [
      "HDMI-A-1"
      "DP-1"
      "eDP-1"
    ]
    [
      "HDMI-A-1"
      "DP-1"
    ]
    [
      "HDMI-A-1"
      "eDP-1"
    ]
    [
      "DP-1"
      "eDP-1"
    ]
    [ "HDMI-A-1" ]
    [ "DP-1" ]
    [ "eDP-1" ]
  ];
in
{
  services.kanshi = {
    enable = true;
    systemdTarget = "dwl-session.target";
    settings = map (names: {
      profile = {
        name = lib.concatStringsSep "-" names;
        outputs = map (
          name:
          displays.${name}
          // {
            criteria = name;
            status = if name == "eDP-1" && builtins.length names > 1 then "disable" else "enable";
            position = if names == [ "eDP-1" ] then "0,0" else displays.${name}.position;
          }
        ) names;
      };
    }) connectedSets;
  };
}
