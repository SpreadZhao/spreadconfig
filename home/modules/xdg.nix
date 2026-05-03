{
  config,
  pkgs,
  scriptsDir,
  spreadconfigDir,
  ...
}:

{
  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
    };
    configFile = {
      # "foot".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/foot";
      # "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/swaylock";
      # "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/fuzzel";
      # "mpv".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/mpv";
    };
    dataFile = {
      "fcitx5/rime/rime-data".source = "${pkgs.rime-ice}/share/rime-data";
      "fcitx5/rime/default.custom.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/default.custom.yaml";
      # "fcitx5/themes/catppuccin-mocha-rosewater".source =
      #     config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/fcitx5-catppuccin/src/catppuccin-mocha-rosewater";
    };
    desktopEntries = {
      toggle_monitor = {
        name = "Toggle Monitor";
        comment = "Toggle Monitor on and off";
        exec = "${scriptsDir}/niri/niri_toggle_output.sh";
        type = "Application";
        icon = "";
      };
      foot_new_tab = {
        name = "Foot New Tab";
        type = "Application";
        exec = "${scriptsDir}/niri/foot_new_tab.sh";
        icon = "";
        terminal = false;
      };
      # kitty_new_tab = {
      #   name = "Kitty New Tab";
      #   type = "Application";
      #   exec = "${scriptsDir}/niri/kitty_new_tab.sh";
      #   icon = "";
      #   terminal = false;
      # };
      change_audio = {
        name = "Change Audio Device";
        type = "Application";
        exec = "/usr/bin/env python3 ${scriptsDir}/util/change_audio.py";
        icon = "";
        categories = [
          "AudioVideo"
          "Utility"
        ];
      };
      shutdown = {
        name = "Shutdown";
        type = "Application";
        exec = "systemctl poweroff";
        icon = "";
        terminal = false;
      };
      reboot = {
        name = "Reboot";
        type = "Application";
        exec = "systemctl reboot";
        icon = "";
        terminal = false;
      };
      sleep = {
        name = "Sleep";
        type = "Application";
        exec = "systemctl sleep";
        icon = "";
        terminal = false;
      };
      suspend = {
        name = "Suspend";
        type = "Application";
        exec = "systemctl suspend";
        icon = "";
        terminal = false;
      };
      wechat = {
        name = "wechat";
        exec = "${scriptsDir}/util/start_wechat.sh";
        terminal = false;
        icon = "wechat";
        type = "Application";
        categories = [
          "Utility"
        ];
      };
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
      niri_set_dynamic_target = {
        name = "niri_set_dynamic_target";
        exec = "${scriptsDir}/niri/niri_set_dynamic_target.sh";
        type = "Application";
        icon = "";
        terminal = false;
      };
      niri_focus_window = {
        name = "niri_focus_window";
        exec = "${scriptsDir}/niri/niri_focus_window.sh";
        type = "Application";
        icon = "";
        terminal = false;
      };
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "org.qutebrowser.qutebrowser.desktop";
        "image/bmp" = "feh.desktop";
        "image/gif" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/jpg" = "feh.desktop";
        "image/pjpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        "image/tiff" = "feh.desktop";
        "image/webp" = "feh.desktop";
        "image/x-bmp" = "feh.desktop";
        "image/x-pcx" = "feh.desktop";
        "image/x-png" = "feh.desktop";
        "image/x-portable-anymap" = "feh.desktop";
        "image/x-portable-bitmap" = "feh.desktop";
        "image/x-portable-graymap" = "feh.desktop";
        "image/x-portable-pixmap" = "feh.desktop";
        "image/x-tga" = "feh.desktop";
        "image/x-xbitmap" = "feh.desktop";
        "image/heic" = "feh.desktop";
        "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      };
      associations.added = {
        "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      };
    };
    portal = {
      enable = true;
      configPackages = with pkgs; [
        # xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      extraPortals = with pkgs; [
        # xdg-desktop-portal-wlr
        xdg-desktop-portal-termfilechooser
      ];
      config = {
        common = {
          default = [
            "gnome"
          ];
          "org.freedesktop.impl.portal.Secret" = [
            "pass-secret-service"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [
            "termfilechooser"
          ];
        };
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      extraConfig = {
        LIB = "${config.home.homeDirectory}/Lib";
        WORKSPACE = "${config.home.homeDirectory}/workspaces";
        TEMP = "${config.home.homeDirectory}/temp";
        SATTY = "${config.xdg.userDirs.pictures}/satty";
        SCREENSHOT = "${config.xdg.userDirs.pictures}/screenshot";
        SCREENRECORD = "${config.xdg.userDirs.videos}/screenrecord";
        APP = "${config.home.homeDirectory}/app";
      };
    };
  };
}
