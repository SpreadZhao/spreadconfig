{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    size = 36;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
    x11.enable = true;
    dotIcons.enable = true;
    hyprcursor = {
      enable = false;
      size = 36;
    };
  };
}
