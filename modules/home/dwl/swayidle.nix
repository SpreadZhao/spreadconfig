{ pkgs, ... }:

let
  restoreDisplays = "${pkgs.wlopm}/bin/wlopm --on '*'";
  # Nix's swaylock wrapper changes the process name but preserves argv[0].
  lock =
    "${pkgs.procps}/bin/pgrep -u \"$(${pkgs.coreutils}/bin/id -u)\" -f '^([^ ]*/)?swaylock( |$)' > /dev/null"
    + " || ${pkgs.swaylock}/bin/swaylock -f";
in

{
  services.swayidle = {
    enable = true;
    systemdTargets = [ "dwl-session.target" ];
    extraArgs = [
      "-C"
      "/dev/null"
      "-w"
    ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.wlopm}/bin/wlopm --off '*'";
        resumeCommand = restoreDisplays;
      }
      {
        timeout = 605;
        command = lock;
      }
    ];
    events = {
      "before-sleep" = lock;
      "after-resume" = restoreDisplays;
    };
  };

  systemd.user.services.swayidle.Service.ExecStopPost = "-${restoreDisplays}";
}
