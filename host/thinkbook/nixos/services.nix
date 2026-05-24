{ lib, ... }:

{
  services = {
    lact.enable = true;

    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = lib.mkDefault 0;
        STOP_CHARGE_THRESH_BAT0 = lib.mkDefault 1;
      };
    };
  };
}
