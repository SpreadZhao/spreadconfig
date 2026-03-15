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
                    command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
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
