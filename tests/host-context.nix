{
  lib,
  mkHost,
  hosts,
}:

let
  declaration = {
    system = "x86_64-linux";
    formFactor = "desktop";
    cpu.vendor = "intel";
    gpu.devices = [
      {
        vendor = "nvidia";
        kind = "discrete";
      }
    ];
    capabilities = {
      battery = false;
      backlight = false;
      bluetooth = null;
    };
    profile = {
      nixos = { };
      home = { };
    };
    modules = {
      nixos = [ ];
      home = [ ];
    };
  };
  synthetic =
    overrides:
    mkHost {
      name = "test-host";
      declaration = lib.recursiveUpdate declaration overrides;
    };
  evaluated = value: (builtins.tryEval (builtins.deepSeq value true)).success;
  nvidiaOnly = synthetic { };
  hybrid = synthetic {
    formFactor = "laptop";
    gpu.devices = declaration.gpu.devices ++ [
      {
        vendor = "intel";
        kind = "integrated";
      }
    ];
  };
in
lib.runTests {
  testCpuDoesNotImplyGpu = {
    expr = {
      inherit (nvidiaOnly.cpu) isIntel isAmd;
      inherit (nvidiaOnly.gpu) hasIntel hasAmd hasNvidia;
    };
    expected = {
      isIntel = true;
      isAmd = false;
      hasIntel = false;
      hasAmd = false;
      hasNvidia = true;
    };
  };
  testHybridGpu = {
    expr = hybrid.gpu.hasIntel && hybrid.gpu.hasNvidia && !hybrid.gpu.hasAmd;
    expected = true;
  };
  testHostIdentityAndFormFactor = {
    expr =
      nvidiaOnly.is "test-host"
      && !nvidiaOnly.is "other-host"
      && nvidiaOnly.isDesktop
      && !nvidiaOnly.isLaptop
      && hybrid.isLaptop
      && !hybrid.isDesktop;
    expected = true;
  };
  testUnknownCapabilityRemainsUnknown = {
    expr = nvidiaOnly.capabilities.bluetooth;
    expected = null;
  };
  testMissingCpuFamilyRemainsUnknown = {
    expr = nvidiaOnly.cpu.family;
    expected = null;
  };
  testRejectRocmWithoutAmdGpu = {
    expr = evaluated (synthetic {
      profile.nixos.rocmSupport = true;
    });
    expected = false;
  };
  testRejectIntelRendererWithoutIntelGpu = {
    expr = evaluated (synthetic {
      profile.home.qutebrowser.renderer = "intel-vulkan";
    });
    expected = false;
  };
  testHybridIntelRendererAccepted = {
    expr = evaluated (synthetic {
      gpu.devices = hybrid.gpu.devices;
      profile.home.qutebrowser.renderer = "intel-vulkan";
    });
    expected = true;
  };
  testHostRocmPolicies = {
    expr = lib.mapAttrs (_: host: host.profile.nixos.rocmSupport) hosts;
    expected = {
      desktop1 = false;
      zephyrus-m16 = false;
      thinkbook = true;
      amd-desktop = true;
    };
  };
  testRealHostGpuFacts = {
    expr =
      hosts.desktop1.cpu.isIntel
      && !hosts.desktop1.gpu.hasIntel
      && hosts.desktop1.gpu.hasNvidia
      && hosts.zephyrus-m16.gpu.hasIntel
      && hosts.zephyrus-m16.gpu.hasNvidia
      && hosts.thinkbook.gpu.hasAmd
      && hosts.amd-desktop.gpu.hasAmd;
    expected = true;
  };
  testHostModulesExist = {
    expr = lib.all (
      host:
      host.modules.nixos != [ ]
      && host.modules.home != [ ]
      && lib.all builtins.pathExists (host.modules.nixos ++ host.modules.home)
    ) (builtins.attrValues hosts);
    expected = true;
  };
  testDesktopBluetoothPolicy = {
    expr =
      !hosts.desktop1.capabilities.bluetooth
      && !hosts.desktop1.profile.nixos.bluetooth.enable
      && !hosts.desktop1.profile.nixos.textbridge.bluetooth.enable;
    expected = true;
  };
} == [ ]
