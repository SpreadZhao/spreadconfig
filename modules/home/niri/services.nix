{ pkgs, scriptsDir, ... }:

{
  systemd.user.services = {
    niri = {
      Unit = {
        Description = "A scrollable-tilling Wayland compositor";
        BindsTo = [ "graphical-session.target" ];
        Before = [
          "graphical-session.target"
          "xdg-desktop-autostart.target"
        ];
        After = [ "graphical-session-pre.target" ];
        Wants = [
          "graphical-session-pre.target"
          "xdg-desktop-autostart.target"
          "waybar.service"
        ];
      };
      Service = {
        Slice = "session.slice";
        Type = "notify";
        ExecStart = "${pkgs.niri}/bin/niri --session";
      };
    };
    niri-window-detect = {
      Unit = {
        Description = "Niri window change watcher";
        After = [
          "niri.service"
        ];
        BindsTo = [
          "niri.service"
        ];
        PartOf = [
          "niri.service"
        ];
      };
      Service = {
        ExecStart = "${scriptsDir}/niri/detect_niri_window_change.sh";
        Restart = "always";
        RestartSec = 2;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install = {
        WantedBy = [
          "graphical-session.target"
        ];
      };
    };
  };
}
