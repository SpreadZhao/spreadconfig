{ lib, ... }:

{
  imports = [
    ./services/asusd.nix
  ];

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = lib.mkForce 0;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 100;
    };
  };
}
