{
  appEntries,
  fontFamilies,
  inputs,
  pkgs,
  repoTree,
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
  spreadDwl = inputs.spread-dwl.packages.${pkgs.stdenv.hostPlatform.system}.spread-dwl.override {
    theme = {
      background = "#${theme_background}";
      border = "#${theme_bright_dark}";
      focus = "#${theme_bright_white}";
      urgent = "#${theme_bright_red}";
      barFg = "#${theme_white}";
      barBg = "#${theme_background}";
      barSelFg = "#${theme_bright_yellow}";
      barSelBg = "#${theme_bright_background}";
      font = "${fontFamilies.mono}:size=14";
    };
  };
  dwlSession = pkgs.writeShellScriptBin "dwl-session" ''
    "${scriptsDir}/dwl/dwl_status.sh" | ${spreadDwl}/bin/dwl -s "${scriptsDir}/dwl/dwl_session.sh" "$@"
    systemctl --user stop dwl-session.target graphical-session.target || true
    systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP || true
  '';
in
{
  imports = [
    ./scripts.nix
    ./services.nix
  ];

  home.packages = [
    spreadDwl
    dwlSession
    pkgs.wlr-randr
    pkgs.wlopm
    pkgs.xwayland
  ];

  xdg.desktopEntries = {
    toggle_monitor = {
      name = "Toggle Monitor";
      comment = "Toggle Monitor on and off";
      exec = "${scriptsDir}/dwl/dwl_toggle_output.sh";
      type = "Application";
      icon = "";
    };
    lock_policy = {
      name = "Lock Policy";
      comment = "Control automatic locking and monitor power";
      exec = "${scriptsDir}/dwl/lock_policy.sh";
      type = "Application";
      icon = "";
      terminal = false;
    };
  };

  xdg.configFile."dwl".source = repoTree "dwl-config" (appEntries "dwl" "files");
}
