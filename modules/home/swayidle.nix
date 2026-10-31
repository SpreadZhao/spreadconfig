{ pkgs, ... }:

let
  restoreDisplays = "${pkgs.wlopm}/bin/wlopm --on '*'";
in

{
  services.swayidle =
    let
      lock = "${pkgs.swaylock}/bin/swaylock";
    in
    {
      enable = true;
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
}
