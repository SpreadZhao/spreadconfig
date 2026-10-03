{
  pkgs,
  config,
  host,
  lib,
  ...
}:

let
  virtualCamera = host.profile.nixos.virtualCamera;
in

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = lib.optional virtualCamera.enable config.boot.kernelPackages.v4l2loopback;
    kernelPackages = pkgs.linuxPackages;
    kernelModules = lib.optional virtualCamera.enable "v4l2loopback";
    # see:
    # https://wiki.archlinux.org/title/V4l2loopback#Loading_the_kernel_module
    # https://wiki.nixos.org/wiki/OBS_Studio#Using_the_Virtual_Camera
    extraModprobeConfig = lib.optionalString virtualCamera.enable ''
      options v4l2loopback devices=1 video_nr=${toString virtualCamera.videoNumber} card_label="OBS Camera" exclusive_caps=1
    '';
    tmp = {
      cleanOnBoot = false;
    };
  };
}
