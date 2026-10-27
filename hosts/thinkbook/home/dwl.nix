{ pkgs, ... }:
{
  spreadconfig.dwl.startupCommands = ''
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --scale 1 --pos 0,0 2>/dev/null || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output DP-2 --scale 1 --pos 3440,180 2>/dev/null || true
    ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2 --pos 5360,500 2>/dev/null || true
  '';
  wayland.windowManager.dwl.settings.SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
}
