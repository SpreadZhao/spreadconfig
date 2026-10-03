{
  system = "x86_64-linux";
  formFactor = "laptop";
  cpu.vendor = "amd";
  gpu.devices = [
    {
      vendor = "amd";
      kind = "integrated";
    }
  ];
  capabilities = {
    battery = true;
    backlight = true;
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
