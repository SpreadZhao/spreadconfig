{
  config,
  lib,
  repoLink,
  repoTree,
  pkgs,
  scriptsDir,
  ...
}:

{
  imports = [ ./scripts.nix ];

  options.spreadconfig.apps.niri.hostConfig = lib.mkOption {
    type = lib.types.str;
    description = "Repository-relative path to this host's native Niri configuration fragment.";
  };

  config = {
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

    xdg.configFile."niri".source = repoTree "niri-config" {
      "config.kdl" = repoLink "modules/home/niri/files/config.kdl";
      "common.kdl" = repoLink "modules/home/niri/files/common.kdl";
      "host.kdl" = repoLink config.spreadconfig.apps.niri.hostConfig;
    };
  };
}
