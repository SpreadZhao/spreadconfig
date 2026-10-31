{ ... }:
{
  spreadconfig.dwl.displayCommands = ''
    wlr-randr --output eDP-1 --on --scale 2 --pos 0,0 || true
  '';
  wayland.windowManager.dwl.settings.SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
}
