{
  config,
  host,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
  ];

  boot = {
    loader.systemd-boot.consoleMode = "2";
    kernelParams = [ "video=efifb:auto" ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      dynamicBoost.enable = true;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      prime = {
        offload = {
          enable = lib.mkDefault true;
          enableOffloadCmd = lib.mkDefault true;
        };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  assertions = [
    {
      assertion = host.isLaptop && host.gpu.hasIntel && host.gpu.hasNvidia;
      message = "Zephyrus PRIME policy requires the declared Intel/NVIDIA hybrid laptop.";
    }
  ];
}
