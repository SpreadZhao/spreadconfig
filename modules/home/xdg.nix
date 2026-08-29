{
  config,
  lib,
  pkgs,
  scriptsDir,
  spreadconfigDir,
  ...
}:

let
  disabledFcitxAutostart = pkgs.writeTextDir "share/applications/org.fcitx.Fcitx5.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Fcitx 5
    Hidden=true
  '';

  drawioMimePackage = pkgs.writeTextDir "share/mime/packages/drawio.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/vnd.jgraph.mxfile">
        <comment>draw.io diagram</comment>
        <glob pattern="*.drawio" weight="80"/>
        <glob pattern="*.drawio.xml" weight="80"/>
      </mime-type>
    </mime-info>
  '';

  desktopApps = {
    antigravity = "antigravity.desktop";
    browser = "org.qutebrowser.qutebrowser.desktop";
    chromium = "chromium-browser.desktop";
    clash = "clash-verge.desktop";
    codex = "codex-desktop.desktop";
    drawio = "drawio.desktop";
    editor = "nvim.desktop";
    element = "element-desktop.desktop";
    feishu = "bytedance-feishu.desktop";
    fileManager = "lf.desktop";
    obsidian = "obsidian.desktop";
    rnote = "com.github.flxzt.rnote.desktop";
    swayimg = "swayimg.desktop";
    telegram = "org.telegram.desktop.desktop";
    waydroidInstaller = "waydroid.app.install.desktop";
    waydroidMarket = "waydroid.market.desktop";
    wemeet = "wemeetapp.desktop";
    xournal = "com.github.xournalpp.xournalpp.desktop";
    zathura = "org.pwmt.zathura.desktop";
    zcode = "zcode.desktop";
  };

  defaultsFor = application: mimeTypes: lib.genAttrs mimeTypes (_: application);

  defaultApplications =
    defaultsFor desktopApps.editor [
      "application/json"
      "application/schema+json"
      "application/sql"
      "application/toml"
      "application/x-ndjson"
      "application/x-shellscript"
      "application/xml"
      "application/yaml"
      "text/css"
      "text/javascript"
      "text/markdown"
      "text/plain"
      "text/rust"
      "text/vnd.trolltech.linguist"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-cmake"
      "text/x-csrc"
      "text/x-go"
      "text/x-java"
      "text/x-kotlin"
      "text/x-lua"
      "text/x-makefile"
      "text/x-python"
      "text/x-python3"
      "text/x-tex"
      "text/xml"
      "text/x-yaml"
      "text/yaml"
    ]
    // defaultsFor desktopApps.browser [
      "application/xhtml+xml"
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/qute"
      "x-scheme-handler/unknown"
    ]
    // defaultsFor desktopApps.zathura [
      "application/pdf"
    ]
    // defaultsFor desktopApps.swayimg [
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/heic"
      "image/heif"
      "image/jpeg"
      "image/jpg"
      "image/jxl"
      "image/pbm"
      "image/pjpeg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/webp"
      "image/x-bmp"
      "image/x-exr"
      "image/x-pcx"
      "image/x-png"
      "image/x-portable-anymap"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-targa"
      "image/x-tga"
      "image/x-xbitmap"
    ]
    // defaultsFor desktopApps.drawio [
      "application/vnd.jgraph.mxfile"
      "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
      "application/vnd.ms-visio.drawing.main+xml"
      "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
      "application/vnd.ms-visio.stencil.main+xml"
      "application/vnd.ms-visio.template.macroEnabled.main+xml"
      "application/vnd.ms-visio.template.main+xml"
      "application/vnd.visio"
    ]
    // defaultsFor desktopApps.rnote [
      "application/rnote"
    ]
    // defaultsFor desktopApps.xournal [
      "application/x-xoj"
      "application/x-xojpp"
      "application/x-xopp"
      "application/x-xopt"
    ]
    // defaultsFor desktopApps.fileManager [
      "inode/directory"
    ]
    // defaultsFor desktopApps.waydroidInstaller [
      "application/vnd.android.package-archive"
    ]
    // defaultsFor desktopApps.antigravity [
      "x-scheme-handler/antigravity"
    ]
    // defaultsFor desktopApps.chromium [
      "x-scheme-handler/chromium"
    ]
    // defaultsFor desktopApps.clash [
      "x-scheme-handler/clash"
    ]
    // defaultsFor desktopApps.codex [
      "x-scheme-handler/codex"
      "x-scheme-handler/codex-browser-sidebar"
    ]
    // defaultsFor desktopApps.element [
      "x-scheme-handler/element"
      "x-scheme-handler/io.element.desktop"
    ]
    // defaultsFor desktopApps.feishu [
      "x-scheme-handler/feishu"
      "x-scheme-handler/feishu-open"
      "x-scheme-handler/lark"
      "x-scheme-handler/x-feishu"
    ]
    // defaultsFor desktopApps.obsidian [
      "x-scheme-handler/obsidian"
    ]
    // defaultsFor desktopApps.telegram [
      "x-scheme-handler/tg"
      "x-scheme-handler/tonsite"
    ]
    // defaultsFor desktopApps.waydroidMarket [
      "x-scheme-handler/market"
    ]
    // defaultsFor desktopApps.wemeet [
      "x-scheme-handler/wemeet"
    ]
    // defaultsFor desktopApps.zcode [
      "x-scheme-handler/zcode"
    ];
in
{
  home.packages = [ drawioMimePackage ];

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      readOnly = true;
      entries = [
        "${disabledFcitxAutostart}/share/applications/org.fcitx.Fcitx5.desktop"
      ];
    };
    configFile = { };
    dataFile = {
      "fcitx5/rime/rime-data".source = "${pkgs.rime-ice}/share/rime-data";
      "fcitx5/rime/default.custom.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/default.custom.yaml";
      "fcitx5/rime/rime_ice.custom.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/rime_ice.custom.yaml";
      # "fcitx5/themes/catppuccin-mocha-rosewater".source =
      #     config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/fcitx5-catppuccin/src/catppuccin-mocha-rosewater";
    };
    desktopEntries = {
      change_audio = {
        name = "Change Audio Device";
        type = "Application";
        exec = "${pkgs.python3}/bin/python3 ${scriptsDir}/util/change_audio.py";
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
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplicationPackages = with pkgs; [
        swayimg
        mpv
        libreoffice-stable
        drawio
        rnote
        xournalpp
      ];
      inherit defaultApplications;
      associations.added =
        defaultsFor desktopApps.zathura [ "application/pdf" ]
        // defaultsFor desktopApps.antigravity [ "x-scheme-handler/antigravity" ]
        // defaultsFor desktopApps.telegram [
          "x-scheme-handler/tg"
          "x-scheme-handler/tonsite"
        ];
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
