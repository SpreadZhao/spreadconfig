{
  config,
  host,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  # c59305b boots but niri fails to create an EGL device on this GTX 1650.
  # Keep this compositor and driver stack pinned until a newer stack passes
  # a boot test. Other hosts and packages use current nixpkgs.
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
  # Home Manager uses the same niri build.
  nixpkgs.overlays = [ (_final: _prev: { inherit (graphicsPkgs) niri; }) ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      inherit (baseline.hardware.graphics) package package32;
      extraPackages = lib.mkForce baseline.hardware.graphics.extraPackages;
      extraPackages32 = lib.mkForce baseline.hardware.graphics.extraPackages32;
    };

    # This desktop uses NVIDIA directly, without laptop PRIME or ASUS services.
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
      message = "desktop1 graphics fallback requires its declared Intel/NVIDIA hardware.";
    }
  ];
}
