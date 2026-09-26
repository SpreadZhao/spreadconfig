{ pkgs, scriptsDir, ... }:

let
  wechat = pkgs.callPackage "${pkgs.path}/pkgs/by-name/we/wechat/linux.nix" {
    pname = "wechat";
    version = "4.1.13";
    meta = pkgs.wechat.meta;
    src = pkgs.fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-T1StKQLs1vb9xWgLc1R/gNVCO/RwsBI3pXmi5bPK7us=";
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
