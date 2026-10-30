{ pkgs, ... }:
{
  spreadconfig.dwl.startupCommands = ''
    ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2 --pos 0,0 2>/dev/null || true
  '';
  wayland.windowManager.dwl.settings.SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
}
