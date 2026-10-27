{ pkgs, ... }:

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
          resumeCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
        }
        {
          timeout = 605;
          command = lock;
        }
      ];
      events = {
        "before-sleep" = lock;
      };
    };
}
