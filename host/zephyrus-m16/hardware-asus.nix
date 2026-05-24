{
  config,
  lib,
  ...
}:

{
  networking.hostName = lib.mkForce "zephyrus-m16";

  boot.kernelModules = lib.mkAfter [ "kvm-intel" ];

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        offload = {
          enable = lib.mkDefault true;
          enableOffloadCmd = lib.mkDefault true;
        };
        # nixos-hardware/asus/zephyrus/gu603h sets these to the common GU603 layout:
        # intelBusId = "PCI:0:2:0";
        # nvidiaBusId = "PCI:1:0:0";
        # Override here if `lspci` reports different bus IDs on your exact machine.
      };
    };
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;

    # LACT is useful for the ThinkBook's AMD GPU, but not for this Intel/NVIDIA laptop.
    lact.enable = lib.mkForce false;

    tlp.settings = {
      START_CHARGE_THRESH_BAT0 = lib.mkForce 0;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 100;
    };
  };
}
