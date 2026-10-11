{ lib }:

# This context is constructed before module evaluation. Keep it independent of
# config and pkgs so it is safe to use in imports and package-set selection.
{ name, declaration }:
let
  cpu = {
    family = null;
  }
  // declaration.cpu;
  devices = declaration.gpu.devices;
  hasGpu = vendor: lib.any (device: device.vendor == vendor) devices;
  capabilities = {
    battery = null;
    backlight = null;
    bluetooth = null;
  }
  // (declaration.capabilities or { });
  profile = lib.recursiveUpdate {
    nixos = {
      rocmSupport = false;
      bluetooth.enable = true;
      textbridge.bluetooth.enable = true;
      upower.enable = true;
      virtualCamera = {
        enable = true;
        videoNumber = 1;
      };
    };
    home = {
      qutebrowser = {
        scaleFactor = 1.5;
        renderer = "default";
      };
      waybar = {
        height = 30;
        fontSize = 20;
        temperaturePath = null;
      };
      obs.plugins = [
        "obs-backgroundremoval"
        "obs-pipewire-audio-capture"
        "obs-vaapi"
      ];
      devices = {
        camera = "/dev/video0";
        battery = "BAT0";
        backlight = null;
      };
    };
  } (declaration.profile or { });
  renderer = profile.home.qutebrowser.renderer;
  require = condition: message: lib.asserts.assertMsg condition "host ${name}: ${message}";
in
assert require (builtins.isString name && name != "") "name must be nonempty";
assert require (builtins.elem declaration.formFactor [
  "laptop"
  "desktop"
]) "invalid formFactor";
assert require (builtins.elem cpu.vendor [
  "intel"
  "amd"
  "arm"
  "other"
]) "invalid CPU vendor";
assert require (
  cpu.family == null || builtins.isString cpu.family
) "CPU family must be a string or null";
assert require (lib.all (
  device:
  builtins.elem device.vendor [
    "intel"
    "amd"
    "nvidia"
    "other"
  ]
  && builtins.elem device.kind [
    "integrated"
    "discrete"
  ]
) devices) "invalid GPU vendor or kind";
assert require (lib.all (value: value == null || builtins.isBool value) (
  lib.attrValues capabilities
)) "capabilities must be booleans or null (unknown)";
assert require (
  !profile.nixos.rocmSupport || hasGpu "amd"
) "global ROCm support requires an AMD GPU";
assert require (builtins.elem renderer [
  "default"
  "intel-vulkan"
]) "invalid qutebrowser renderer";
assert require (
  renderer != "intel-vulkan" || (hasGpu "intel" && hasGpu "nvidia")
) "Intel Vulkan workaround requires Intel and NVIDIA GPUs";
assert require (
  builtins.isAttrs declaration.modules
  && lib.all builtins.isPath (declaration.modules.nixos ++ declaration.modules.home)
) "module lists must contain paths";
{
  inherit name capabilities profile;
  inherit (declaration) system formFactor modules;
  is = candidate: name == candidate;
  isLaptop = declaration.formFactor == "laptop";
  isDesktop = declaration.formFactor == "desktop";
  cpu = cpu // {
    isIntel = cpu.vendor == "intel";
    isAmd = cpu.vendor == "amd";
  };
  gpu = {
    inherit devices;
    hasIntel = hasGpu "intel";
    hasAmd = hasGpu "amd";
    hasNvidia = hasGpu "nvidia";
  };
}
