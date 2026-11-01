{
  config,
  lib,
  fontFamilies,
  inputs,
  pkgs,
  scriptsDir,
  theme_background,
  theme_bright_background,
  theme_bright_dark,
  theme_bright_red,
  theme_bright_white,
  theme_bright_yellow,
  theme_white,
  ...
}:
let
  dwlSession = pkgs.writeShellApplication {
    name = "dwl-session";
    runtimeInputs = [
      config.wayland.windowManager.dwl.finalPackage
      config.programs.slstatus.finalPackage
      pkgs.systemd
      pkgs.dbus
      pkgs.wlopm
    ];
    runtimeEnv = {
      DWL_SESSION_PROFILE = config.home.profileDirectory;
      DWL_IMPORT_VARIABLES = lib.concatStringsSep " " config.wayland.windowManager.dwl.systemd.variables;
    };
    text = builtins.readFile ./scripts/dwl/dwl-session.sh;
  };
in
{
  imports = [
    inputs.spreadless.homeManagerModules.dwl
    ./scripts.nix
    ./services.nix
    ./swayidle.nix
    ./tray.nix
  ];

  config = {
    wayland.windowManager.dwl = {
      enable = true;
      systemd.variables = [
        "WAYLAND_DISPLAY"
        "DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "XDG_SESSION_DESKTOP"
        "PATH"
        "SCRIPT_HOME"
      ];
      modkey = "WLR_MODIFIER_LOGO";
      rootcolor = "0x${theme_background}ff";
      colors = {
        norm = {
          fg = "0x${theme_white}ff";
          bg = "0x${theme_background}ff";
          border = "0x${theme_bright_dark}ff";
        };
        sel = {
          fg = "0x${theme_bright_yellow}ff";
          bg = "0x${theme_bright_background}ff";
          border = "0x${theme_bright_white}ff";
        };
        urg = {
          fg = "0xffffffff";
          bg = "0x${theme_bright_red}ff";
          border = "0x${theme_bright_red}ff";
        };
      };
      fonts = [
        "${fontFamilies.sans}:size=14"
        "Noto Sans CJK SC:size=14"
        "Symbols Nerd Font:size=14"
        "${fontFamilies.emoji}:size=14"
      ];
      barHpad = 2;
      statusRpad = 2;
      rules = [
        {
          appId = "dropdown-foot";
          isFloating = true;
          floatW = 0.80;
          floatH = 0.50;
          floatY = 0;
        }
        {
          appId = "lick-foot";
          isFloating = true;
          floatW = 0.75;
          floatH = 0.60;
          floatY = -1;
        }
        {
          appId = "swayimg-pin";
          isFloating = true;
        }
        {
          appId = "satty";
          isFloating = true;
        }
        {
          appId = "jetbrains";
          title = "Welcome";
          isFloating = true;
        }
      ];
      binds = {
        # Applications and external scripts
        "MODKEY, XKB_KEY_Return" = ''spawn, {.v = (const char*[]){ "footclient", NULL }}'';
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return" = ''spawn, SHCMD("footclient -a dropdown-foot")'';
        "MODKEY, XKB_KEY_space" = ''spawn, {.v = (const char*[]){ "fuzzel", NULL }}'';
        "MODKEY, XKB_KEY_b" = "togglebar, {0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_l" = ''spawn, SHCMD("swaylock")'';
        "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_l" =
          ''spawn, SHCMD("\"''${SCRIPT_HOME:-$HOME/scripts}/dwl/dwl_lock.sh\"")'';
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_a" =
          ''spawn, SHCMD("\"''${SCRIPT_HOME:-$HOME/scripts}/util/screenshot.sh\"")'';
        "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_a" =
          ''spawn, SHCMD("\"''${SCRIPT_HOME:-$HOME/scripts}/util/screenshot.sh\" -o")'';
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_v" =
          ''spawn, SHCMD("\"''${SCRIPT_HOME:-$HOME/scripts}/util/clipboard_history.sh\"")'';
        "MODKEY, XKB_KEY_t" = ''spawn, SHCMD("\"''${SCRIPT_HOME:-$HOME/scripts}/dwl/tray.sh\"")'';
        "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_n" =
          ''spawn, SHCMD("notification-history browse")'';
        "MODKEY, XKB_KEY_z" = ''spawn, SHCMD("shmooz")'';

        # Media and hardware keys
        "0, XKB_KEY_XF86AudioRaiseVolume" =
          ''spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0")'';
        "0, XKB_KEY_XF86AudioLowerVolume" = ''spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-")'';
        "0, XKB_KEY_XF86AudioMute" = ''spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'';
        "0, XKB_KEY_XF86AudioMicMute" = ''spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'';
        "0, XKB_KEY_XF86MonBrightnessUp" = ''spawn, SHCMD("brightnessctl --class=backlight set +10%")'';
        "0, XKB_KEY_XF86MonBrightnessDown" = ''spawn, SHCMD("brightnessctl --class=backlight set 10%-")'';

        # Window focus and stack management
        "MODKEY, XKB_KEY_j" = "focusstack, {.i = +1}";
        "MODKEY, XKB_KEY_k" = "focusstack, {.i = -1}";
        "MODKEY, XKB_KEY_BackSpace" = "zoom, {0}";
        "MODKEY, XKB_KEY_i" = "incnmaster, {.i = +1}";
        "MODKEY, XKB_KEY_d" = "incnmaster, {.i = -1}";
        "MODKEY, XKB_KEY_h" = "setmfact, {.f = -0.05f}";
        "MODKEY, XKB_KEY_l" = "setmfact, {.f = +0.05f}";

        # Layouts and window states
        "MODKEY, XKB_KEY_m" = "cyclelayout, {0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_h" = "setmfact, {.f = 1.5f}";
        "MODKEY, XKB_KEY_f" = "togglefullscreen, {0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f" = "togglefloating, {0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c" = "killclient, {0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q" = "quit, {0}";

        # Multi-monitor focus and window movement
        "MODKEY, XKB_KEY_comma" = "focusmon, {.i = WLR_DIRECTION_LEFT}";
        "MODKEY, XKB_KEY_period" = "focusmon, {.i = WLR_DIRECTION_RIGHT}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_comma" = "tagmon, {.i = WLR_DIRECTION_LEFT}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_period" = "tagmon, {.i = WLR_DIRECTION_RIGHT}";

        # Tags
        "MODKEY, XKB_KEY_Tab" = "view, {0}";
        "MODKEY, XKB_KEY_0" = "view, {.ui = ~0}";
        "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_0" = "tag, {.ui = ~0}";
      }
      // lib.mergeAttrsList (
        lib.genList (
          i:
          let
            key = "XKB_KEY_${toString (i + 1)}";
            arg = "{.ui = 1 << ${toString i}}";
          in
          {
            "MODKEY, ${key}" = "view, ${arg}";
            "MODKEY|WLR_MODIFIER_CTRL, ${key}" = "toggleview, ${arg}";
            "MODKEY|WLR_MODIFIER_SHIFT, ${key}" = "tag, ${arg}";
            "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, ${key}" = "toggletag, ${arg}";
          }
        ) 9
      )
      // builtins.listToAttrs (
        lib.genList (i: {
          name = "MODKEY|WLR_MODIFIER_CTRL, XKB_KEY_F${toString (i + 1)}";
          value = "chvt, {.ui = ${toString (i + 1)}}";
        }) 12
      );
      buttons = [
        "MODKEY, BTN_LEFT, moveresize, {.ui = CurMove}, ClkClient"
        "MODKEY, BTN_RIGHT, moveresize, {.ui = CurResize}, ClkClient"
        "0, BTN_LEFT, view, {0}, ClkTagBar"
        "0, BTN_RIGHT, toggleview, {0}, ClkTagBar"
        "MODKEY, BTN_LEFT, tag, {0}, ClkTagBar"
        "MODKEY, BTN_RIGHT, toggletag, {0}, ClkTagBar"
      ];
    };
    programs.slstatus.enable = true;
    home.packages = [
      dwlSession
      pkgs.wlopm
    ];
    xdg.desktopEntries.lock_policy = {
      name = "Lock Policy";
      comment = "Control automatic locking and monitor power";
      exec = "${scriptsDir}/dwl/lock_policy.sh";
      type = "Application";
      icon = "";
      terminal = false;
    };
  };
}
