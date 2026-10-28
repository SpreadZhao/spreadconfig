{ pkgs, ... }:
{
  spreadconfig.dwl.startupCommands = ''
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --mode 3440x1440@100.000 --scale 1.25 --pos 0,0 2>/dev/null || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --scale 1.1 --pos 2752,180 2>/dev/null || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2 --pos 4288,500 --off 2>/dev/null || true
  '';
  wayland.windowManager.dwl.settings.SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
}
