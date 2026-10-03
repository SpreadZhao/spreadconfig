{ host, ... }:

{
  hardware = {
    bluetooth = {
      enable = host.profile.nixos.bluetooth.enable && host.capabilities.bluetooth != false;
      powerOnBoot = host.profile.nixos.bluetooth.enable && host.capabilities.bluetooth != false;
      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };
  };
}
