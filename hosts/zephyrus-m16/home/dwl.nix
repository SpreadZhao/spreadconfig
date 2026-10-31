{ ... }:
{
  spreadconfig.dwl.displayCommands = ''
    wlr-randr --output HDMI-A-1 --on --mode 3440x1440@100.000 --scale 1.25 --pos 0,0 || true
    wlr-randr --output DP-1 --on --scale 1.1 --pos 2752,180 || true
    wlr-randr --output eDP-1 --scale 2 --pos 4288,500 --off || true
  '';
  wayland.windowManager.dwl.settings.SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
}
