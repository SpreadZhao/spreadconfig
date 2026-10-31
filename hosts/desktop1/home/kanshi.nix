{ lib, ... }:
let
  displays = {
    "HDMI-A-1" = {
      scale = 1.0;
      position = "0,0";
    };
    "DP-2" = {
      scale = 1.0;
      position = "3440,180";
    };
    "eDP-1" = {
      scale = 2.0;
      position = "5360,500";
    };
  };
  connectedSets = [
    [
      "HDMI-A-1"
      "DP-2"
      "eDP-1"
    ]
    [
      "HDMI-A-1"
      "DP-2"
    ]
    [
      "HDMI-A-1"
      "eDP-1"
    ]
    [
      "DP-2"
      "eDP-1"
    ]
    [ "HDMI-A-1" ]
    [ "DP-2" ]
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
        outputs = map (name: displays.${name} // { criteria = name; }) names;
      };
    }) connectedSets;
  };
}
