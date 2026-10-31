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
  color = value: { raw = "0x${value}ff"; };
  restoreDisplays = pkgs.writeShellApplication {
    name = "dwl-display-restore";
    runtimeInputs = [
      pkgs.wlopm
      pkgs.wlr-randr
    ];
    text = ''
      wlopm --on '*' || true
      ${config.spreadconfig.dwl.displayCommands}
    '';
  };
  dwlSession = pkgs.writeShellApplication {
    name = "dwl-session";
    runtimeInputs = [
      config.wayland.windowManager.dwl.finalPackage
      config.programs.slstatus.finalPackage
      pkgs.systemd
      pkgs.dbus
      restoreDisplays
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
  ];

  options.spreadconfig.dwl.displayCommands = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Host wlr-randr commands run at login and after waking the displays.";
  };

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
      settings = {
        SDWL_ROOTCOLOR = color theme_background;
        SDWL_NORM_FG = color theme_white;
        SDWL_NORM_BG = color theme_background;
        SDWL_NORM_BORDER = color theme_bright_dark;
        SDWL_SEL_FG = color theme_bright_yellow;
        SDWL_SEL_BG = color theme_bright_background;
        SDWL_SEL_BORDER = color theme_bright_white;
        SDWL_URG_FG = color "ffffff";
        SDWL_URG_BG = color theme_bright_red;
        SDWL_URG_BORDER = color theme_bright_red;
        SDWL_FONT = "${fontFamilies.sans}:size=14";
        SDWL_FONT_FALLBACKS.raw = lib.concatStringsSep ", " (
          map builtins.toJSON [
            "Noto Sans CJK SC:size=14"
            "Symbols Nerd Font:size=14"
            "${fontFamilies.emoji}:size=14"
          ]
        );
        SDWL_BAR_HPAD = 2;
        SDWL_STATUS_RPAD = 2;
      };
    };
    programs.slstatus.enable = true;
    home.packages = [
      dwlSession
      restoreDisplays
      pkgs.dpms-off
      pkgs.wlr-randr
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
