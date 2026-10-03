{
  system = "x86_64-linux";
  formFactor = "desktop";
  cpu = {
    vendor = "intel";
    family = "Core 10th generation";
  };
  # The i5-10400F has no integrated GPU.
  gpu.devices = [
    {
      vendor = "nvidia";
      kind = "discrete";
      model = "GeForce GTX 1650";
    }
  ];
  capabilities = {
    battery = false;
    backlight = false;
    bluetooth = false;
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
