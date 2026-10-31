{ ... }:
{
  spreadconfig.dwl.displayCommands = ''
    wlr-randr --output HDMI-A-1 --on --scale 1 --pos 0,0 || true
    wlr-randr --output DP-2 --on --scale 1 --pos 3440,180 || true
    wlr-randr --output eDP-1 --on --scale 2 --pos 5360,500 || true
  '';
}
