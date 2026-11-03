{ pkgs, scriptsDir, ... }:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.wechat ];

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
