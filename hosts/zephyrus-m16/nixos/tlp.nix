{ lib, ... }:

{
  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_AC = "";
      PLATFORM_PROFILE_ON_BAT = "";
      PLATFORM_PROFILE_ON_SAV = "";
      CPU_ENERGY_PERF_POLICY_ON_AC = "";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "";
      START_CHARGE_THRESH_BAT0 = lib.mkForce 0;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 80;
      USB_DENYLIST = "04e8:6860";
    };
  };
}
