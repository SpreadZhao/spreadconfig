{
  config,
  host,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  # Pin the compositor, kernel, and driver stack for this GTX 1650.
  # Other hosts and desktop1's non-graphics packages use the main nixpkgs input.
  graphicsPkgs = import inputs.nixpkgs-desktop1-graphics {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      rocmSupport = host.profile.nixos.rocmSupport;
    };
  };
  # Use the pinned NixOS module to keep NVIDIA's EGL platform JSON files and
  # both driver architectures consistent, without duplicating its packaging.
  graphicsBaseline = inputs.nixpkgs-desktop1-graphics.lib.nixosSystem {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      ({ config, ... }: {
        nixpkgs.pkgs = graphicsPkgs;
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        hardware.nvidia = {
          open = true;
          modesetting.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      })
    ];
  };
  baseline = graphicsBaseline.config;
in

{
  boot.kernelPackages = lib.mkForce baseline.boot.kernelPackages;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      inherit (baseline.hardware.graphics) package package32;
      extraPackages = lib.mkForce baseline.hardware.graphics.extraPackages;
      extraPackages32 = lib.mkForce baseline.hardware.graphics.extraPackages32;
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

  assertions = [
    {
      assertion = host.cpu.isIntel && host.gpu.hasNvidia;
      message = "desktop1's pinned graphics stack requires its declared Intel/NVIDIA hardware.";
    }
  ];
}
