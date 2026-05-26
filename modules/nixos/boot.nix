{ pkgs, config, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "v4l2loopback" ];
    # see:
    # https://wiki.archlinux.org/title/V4l2loopback#Loading_the_kernel_module
    # https://wiki.nixos.org/wiki/OBS_Studio#Using_the_Virtual_Camera
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Camera" exclusive_caps=1
    '';
    tmp = {
      cleanOnBoot = false;
    };
  };
}
