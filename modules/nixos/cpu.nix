{
  config,
  host,
  lib,
  ...
}:

{
  hardware.cpu = lib.mkMerge [
    (lib.mkIf host.cpu.isIntel {
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    })
    (lib.mkIf host.cpu.isAmd {
      amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    })
  ];
}
