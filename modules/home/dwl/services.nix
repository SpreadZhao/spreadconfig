{ pkgs, ... }:

let
  shutdownMonitor = pkgs.writeShellApplication {
    name = "dwl-shutdown";
    runtimeInputs = [
      pkgs.glib
      pkgs.systemd
    ];
    text = builtins.readFile ./scripts/dwl/dwl-shutdown.sh;
  };
in
{
  # Keep this service outside the targets it stops during PrepareForShutdown.
  systemd.user.services.dwl-shutdown = {
    Unit.Description = "Stop dwl desktop services before shutdown";
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=shutdown --mode=delay --who=dwl-session --why=\"Stop desktop services before ending the session\" ${shutdownMonitor}/bin/dwl-shutdown";
      TimeoutStartSec = 10;
      TimeoutStopSec = 3;
    };
  };

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
