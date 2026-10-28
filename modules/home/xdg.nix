{ config, pkgs, ... }:

{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      # This ordered list is the desktop-wide fallback preference. Explicit
      # MIME and protocol associations live in the application modules.
      defaultApplicationPackages = with pkgs; [
        swayimg
        mpv
        libreoffice-stable
        drawio
        rnote
        xournalpp
      ];
      # Keep the handler for this externally installed application.
      defaultApplications."x-scheme-handler/antigravity" = "antigravity.desktop";
      associations.added."x-scheme-handler/antigravity" = "antigravity.desktop";
    };
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = [
        "wlr"
        "gtk"
      ];
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      extraConfig = {
        LIB = "${config.home.homeDirectory}/Lib";
        WORKSPACE = "${config.home.homeDirectory}/workspaces";
        TEMP = "${config.home.homeDirectory}/temp";
        APP = "${config.home.homeDirectory}/app";
      };
    };
  };
}
