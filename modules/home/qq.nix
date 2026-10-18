{ pkgs, ... }:

{
  home.packages = [ pkgs.qq ];

  xdg.desktopEntries.qq = {
    name = "QQ";
    exec = "${pkgs.qq}/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3 %U";
    icon = "${pkgs.qq}/share/icons/hicolor/512x512/apps/qq.png";
    comment = "QQ";
    categories = [ "Network" ];
    settings.StartupWMClass = "QQ";
  };
}
