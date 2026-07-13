{ pkgs, scriptsDir, ... }:

let
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = pkgs.wechat.version;
    meta = pkgs.wechat.meta;
    src = pkgs.fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-RX26ArkbAxzdRBLu4HT7v/udnQax5Q/Bgi00hw4RSZA=";
    };
  };
in

{
  home.packages = [ wechat ];

  xdg.desktopEntries.wechat = {
    name = "wechat";
    exec = "${scriptsDir}/util/start_wechat.sh";
    terminal = false;
    icon = "wechat";
    type = "Application";
    categories = [
      "Utility"
    ];
  };
}
