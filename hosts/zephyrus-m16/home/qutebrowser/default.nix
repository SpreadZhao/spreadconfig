{
  host,
  lib,
  pkgs,
  ...
}:

{
  assertions = [
    {
      assertion = host.gpu.hasNvidia && host.gpu.hasIntel;
      message = "The qutebrowser Intel Vulkan workaround requires both NVIDIA and Intel GPUs on ${host.name}.";
    }
  ];
  programs.qutebrowser.package = import ../../../../modules/home/qutebrowser/package.nix {
    inherit lib pkgs;
    intelVulkan = true;
  };
}
