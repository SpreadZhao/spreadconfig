{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  niriComputerUse = inputs.niri-computer-use.packages.${system}.aiui;
in
{
  home.packages = [ niriComputerUse ];

  xdg.desktopEntries.aiui-control = {
    name = "AI Desktop Controls";
    comment = "Pause, stop, inspect, or reset Niri computer-use automation";
    exec = "${niriComputerUse}/bin/aiui menu --source launcher";
    icon = "preferences-system";
    categories = [
      "System"
      "Utility"
    ];
    terminal = false;
    type = "Application";
  };
}
