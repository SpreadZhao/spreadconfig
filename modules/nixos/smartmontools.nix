{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.smartmontools ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
