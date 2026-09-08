# Placeholder only. Replace this entire file with nixos-generate-config output
# from the new desktop, after mounting its real root and EFI partitions.
# See README.md in this directory for the installation steps.
{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  assertions = [
    {
      assertion = false;
      message = "amd-desktop: replace hosts/amd-desktop/hardware-configuration.nix with the new machine's generated hardware configuration before building or installing (see hosts/amd-desktop/README.md).";
    }
  ];
}
