{
  hostConfigSource,
  pkgs,
  scriptsDir,
  ...
}:

{
  home.packages = [ pkgs.niri ];

  xdg.desktopEntries = {
    toggle_monitor = {
      name = "Toggle Monitor";
      comment = "Toggle Monitor on and off";
      exec = "${scriptsDir}/niri/niri_toggle_output.sh";
      type = "Application";
      icon = "";
    };
    lock_policy = {
      name = "Lock Policy";
      comment = "Control automatic locking and monitor power";
      exec = "${scriptsDir}/niri/lock_policy.sh";
      type = "Application";
      icon = "";
      terminal = false;
    };
    niri_set_dynamic_target = {
      name = "niri_set_dynamic_target";
      exec = "${scriptsDir}/niri/niri_set_dynamic_target.sh";
      type = "Application";
      icon = "";
      terminal = false;
    };
    niri_focus_window = {
      name = "niri_focus_window";
      exec = "${scriptsDir}/niri/niri_focus_window.sh";
      type = "Application";
      icon = "";
      terminal = false;
    };
  };

  xdg.configFile."niri".source = hostConfigSource "niri";
}
