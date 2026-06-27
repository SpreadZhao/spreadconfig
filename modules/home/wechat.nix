{ pkgs, scriptsDir, ... }:

let
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = pkgs.wechat.version;
    meta = pkgs.wechat.meta;
    src = pkgs.fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-vTTkuFm1LhAqVvuynIfYdROPf19nfCQIOGhw6Z+dOeo=";
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
