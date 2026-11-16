{ host, ... }:

{
  boot = {
    loader.systemd-boot.consoleMode = "2";
    kernelParams = [ "video=efifb:auto" ];
  };

  hardware = {
    amdgpu = {
      opencl.enable = true;
      initrd.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  assertions = [
    {
      assertion = host.cpu.isAmd && host.gpu.hasAmd && host.isLaptop;
      message = "thinkbook hardware policy requires its declared AMD laptop hardware.";
    }
  ];
}
