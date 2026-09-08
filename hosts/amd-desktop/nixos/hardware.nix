{ inputs, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-gpu-amd
  ];

  # Ryzen 9 9950X3D. Keep the shared kernel and its default scheduling policy.
  boot.kernelModules = [ "kvm-amd" ];

  hardware = {
    enableRedistributableFirmware = true;

    # common-gpu-amd provides Mesa/RADV, 32-bit graphics and early AMDGPU loading.
    # OpenCL is an additional policy for the existing compute applications.
    amdgpu.opencl.enable = true;
  };
}
