{ host, ... }:

{
  services.upower.enable = host.profile.nixos.upower.enable;
}
