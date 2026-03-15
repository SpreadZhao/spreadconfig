{ pkgs, ... }:

{
    imports = [
        ./programs
    ];

    environment.systemPackages = with pkgs; [
        wget
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
        clinfo
        nethogs
    ];
}
