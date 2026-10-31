{ ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "dwl-session.target";
    settings = [
      {
        profile = {
          name = "internal";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 2.0;
              position = "0,0";
            }
          ];
        };
      }
    ];
  };
}
