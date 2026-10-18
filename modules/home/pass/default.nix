{
  pkgs,
  config,
  scriptsDir,
  ...
}:

{
  imports = [ ./scripts.nix ];

  home.packages = [ pkgs.pass ];

  home.sessionVariables.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";

  xdg.desktopEntries = {
    pmenu = {
      name = "pmenu";
      exec = "${scriptsDir}/util/bin/pmenu";
      type = "Application";
      icon = "";
      terminal = false;
    };
    pmenu_last = {
      name = "pmenu_last";
      exec = "${scriptsDir}/util/bin/pmenu_last";
      type = "Application";
      icon = "";
      terminal = false;
    };
  };
}
