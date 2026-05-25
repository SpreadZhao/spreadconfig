{ config, lib, ... }:

{
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    amdgpu = {
      opencl.enable = true;
      initrd.enable = false;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
