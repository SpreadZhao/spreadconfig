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
  sessionVariables = "WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP";
  importVariables = lib.escapeShellArgs config.wayland.windowManager.dwl.systemd.variables;
  systemctl = "${pkgs.systemd}/bin/systemctl";
  startup = pkgs.writeShellScript "dwl-startup" ''
    ${systemctl} --user import-environment ${importVariables} || true
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${importVariables} || true
    ${systemctl} --user start dwl-session.target || true
    ${config.spreadconfig.dwl.startupCommands}
  '';
  dwlSession = pkgs.writeShellScriptBin "dwl-session" ''
    if [[ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]]; then
      source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    fi
    status_pid=
    compositor_pid=
    cleanup() {
      for pid in "$compositor_pid" "$status_pid"; do
        if [[ -n "$pid" ]]; then
          kill "$pid" 2>/dev/null || true
          wait "$pid" 2>/dev/null || true
        fi
      done
      ${systemctl} --user stop dwl-session.target graphical-session.target || true
      ${systemctl} --user unset-environment ${sessionVariables} || true
    }
    trap 'cleanup' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    exec {status_fd}< <(exec ${lib.getExe config.programs.slstatus.finalPackage} -s)
    status_pid=$!
    ${lib.getExe config.wayland.windowManager.dwl.finalPackage} -s ${startup} "$@" <&"$status_fd" {status_fd}<&- &
    compositor_pid=$!
    exec {status_fd}<&-
    wait "$compositor_pid"
    result=$?
    compositor_pid=
    exit "$result"
  '';
in
{
  imports = [
    inputs.spread-dwl.homeManagerModules.default
    ./scripts.nix
    ./services.nix
  ];

  options.spreadconfig.dwl.startupCommands = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Host shell commands run once after dwl creates its Wayland socket.";
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
