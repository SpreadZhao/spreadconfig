{ pkgs, scriptsDir, ... }:

let
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = "4.1.13";
    meta = pkgs.wechat.meta;
    src = pkgs.fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-ay4g5wAGNy6N37rkDqhkVkUgyHsH0BYLYA7JP3j9XMI=";
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
