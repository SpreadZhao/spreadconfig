{ ... }:

{
  xdg.desktopEntries = {
    shutdown = {
      name = "Shutdown";
      type = "Application";
      exec = "systemctl poweroff";
      icon = "";
      terminal = false;
    };
    reboot = {
      name = "Reboot";
      type = "Application";
      exec = "systemctl reboot";
      icon = "";
      terminal = false;
    };
    sleep = {
      name = "Sleep";
      type = "Application";
      exec = "systemctl sleep";
      icon = "";
      terminal = false;
    };
    suspend = {
      name = "Suspend";
      type = "Application";
      exec = "systemctl suspend";
      icon = "";
      terminal = false;
    };
  };
}
