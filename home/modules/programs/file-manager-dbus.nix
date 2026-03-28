{ pkgs, scriptsDir, ... }:

{
  home.packages = [ pkgs.file-manager-dbus ];

  xdg.configFile."org.freedesktop.FileManager1.common/config".text = ''
    cmd="${scriptsDir}/util/lf-wrapper-dbus-kitty.sh"
  '';
}
