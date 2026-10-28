{ ... }:

{
  systemd.user.targets.dwl-session = {
    Unit = {
      Description = "dwl compositor session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [
        "graphical-session-pre.target"
        "xdg-desktop-autostart.target"
      ];
      Before = [
        "graphical-session.target"
        "xdg-desktop-autostart.target"
      ];
      After = [ "graphical-session-pre.target" ];
    };
  };
}
