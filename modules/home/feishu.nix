{ pkgs, lib, ... }:

let
  uriSchemes = [
    "x-scheme-handler/feishu"
    "x-scheme-handler/feishu-open"
    "x-scheme-handler/lark"
    "x-scheme-handler/x-feishu"
  ];
in
{
  home.packages = [ pkgs.feishu ];

  xdg.desktopEntries.bytedance-feishu = {
    name = "Feishu";
    exec = "${pkgs.feishu}/bin/bytedance-feishu --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 %U";
    icon = "bytedance-feishu";
    categories = [ "Office" ];
    mimeType = [ "message/rfc822" ] ++ uriSchemes;
    startupNotify = true;
    settings = {
      "Name[zh_CN]" = "飞书";
      X-KDE-DBUS-Restricted-Interfaces = "org.kde.kwin.Screenshot,org.kde.KWin.ScreenShot2";
    };
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs uriSchemes (_: "bytedance-feishu.desktop");
}
