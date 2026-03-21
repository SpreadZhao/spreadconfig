{ pkgs, ... }:

{
  imports = [
    ./programs
  ];

  environment.systemPackages = with pkgs; [
    # Network
    wget

    # System utilities
    brightnessctl
    efibootmgr
    exfatprogs
    jq
    lsof
    net-tools
    ripgrep
    ntfs3g
    usbutils
    pciutils
    file
    killall

    # Monitoring
    clinfo
    nethogs
  ];
}
