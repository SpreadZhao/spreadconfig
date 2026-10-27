{ config, ... }:
{
  programs.satty = {
    enable = true;
    settings = {
      general = {
        early-exit = [ "all" ];
        corner-roundness = 0;
        initial-tool = "brush";
        copy-command = "wl-copy";
        annotation-size-factor = 1;
        output-filename = "${config.xdg.userDirs.pictures}/satty/satty-%Y%m%d-%H%M%S.png";
        save-after-copy = false;
        default-hide-toolbars = false;
        focus-toggles-toolbars = false;
        default-fill-shapes = false;
        primary-highlighter = "block";
        disable-notifications = false;
        actions-on-right-click = [ ];
        actions-on-enter = [ ];
        actions-on-escape = [ "exit" ];
        no-window-decoration = true;
      };
      keybinds = {
        pointer = "p";
        crop = "c";
        brush = "b";
        line = "i";
        arrow = "z";
        rectangle = "r";
        ellipse = "e";
        text = "t";
        marker = "m";
        blur = "u";
        highlight = "g";
      };
      font = {
        family = "Unifont";
        style = "Regular";
      };
      color-palette = {
        palette = [
          "#00ffff"
          "#a52a2a"
          "#dc143c"
          "#ff1493"
          "#ffd700"
          "#008000"
        ];
        custom = [
          "#00ffff"
          "#a52a2a"
          "#dc143c"
          "#ff1493"
          "#ffd700"
          "#008000"
        ];
      };
    };
  };
}
