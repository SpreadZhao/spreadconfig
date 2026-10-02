{ config, lib, ... }:

{
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Preserve the desktop's direct NVIDIA setup from nixos_desktop1.
    # Zephyrus PRIME bus IDs, Dynamic Boost and ASUS services are laptop-specific.
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
