{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d7af7009-dfb2-4c95-baf2-4df6d1a73807";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C446-F9DE";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/data" = {
      device = "/dev/disk/by-uuid/525ef6ef-0aa2-4732-969b-ca9aef4dcf56";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
  };

  swapDevices = [ ];

  # only need when /data was mounted
  systemd.tmpfiles.rules = [
    "d /data/spreadzhao 0755 spreadzhao users -"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
