{ pkgs, scriptsDir, ... }:

{
  home.packages = [ pkgs.org-freedesktop-filemanager1-common ];

  xdg.configFile."org.freedesktop.FileManager1.common/config".text = ''
    cmd="${scriptsDir}/util/lf-wrapper-dbus.sh"
  '';
}
