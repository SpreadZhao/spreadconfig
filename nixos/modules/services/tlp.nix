{ lib, ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      # ThinkBook uses ideapad_laptop driver with lenovo plugin
      # Battery conservation mode: 1 = charge to fixed threshold (60-80%), 0 = charge to 100%
      START_CHARGE_THRESH_BAT0 = lib.mkDefault 0;
      STOP_CHARGE_THRESH_BAT0 = lib.mkDefault 1;
    };
  };
}
