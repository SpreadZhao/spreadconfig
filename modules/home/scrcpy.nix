{ pkgs, ... }:

{
  home.packages = [ pkgs.scrcpy ];

  xdg.desktopEntries = {
    scrcpy = {
      name = "scrcpy";
      genericName = "Android Remote Control";
      comment = "Display and control your Android device";
      exec = ''/bin/sh -c "\\$SHELL -i -c 'scrcpy --render-driver=opengl'"'';
      icon = "scrcpy";
      categories = [
        "Utility"
        "RemoteAccess"
      ];
      startupNotify = false;
      settings.Keywords = "adb;android;screen;mirroring;display;control;phone;device;";
    };
    scrcpy-console = {
      name = "scrcpy (console)";
      exec = "${pkgs.scrcpy}/bin/scrcpy";
      icon = "scrcpy";
      terminal = true;
      settings.Hidden = "true";
    };
  };
}
