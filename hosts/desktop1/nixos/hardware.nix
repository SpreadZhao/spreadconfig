{ config, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # NVIDIA drives this desktop's display directly.
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
