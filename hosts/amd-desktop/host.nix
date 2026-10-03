{
  system = "x86_64-linux";
  formFactor = "desktop";
  cpu = {
    vendor = "amd";
    family = "Ryzen 9000";
  };
  # Planned hardware; PCI addresses and motherboard peripherals await discovery.
  gpu.devices = [
    {
      vendor = "amd";
      kind = "integrated";
    }
    {
      vendor = "amd";
      kind = "discrete";
      model = "Radeon RX 9070 XT";
    }
  ];
  capabilities = {
    battery = false;
    backlight = false;
    bluetooth = null;
  };
  profile = {
    nixos = import ./nixos/profile.nix;
    home = import ./home/profile.nix;
  };
  modules = {
    nixos = [ ./configuration.nix ];
    home = [ ./home.nix ];
  };
}
