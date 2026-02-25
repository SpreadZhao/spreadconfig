{
    lib,
    config,
    pkgs,
    inputs,
    ...
}:
let
    installedJDKs = with pkgs; [
        jdk25
        jdk21
        jdk17
        jdk11
        jdk8
    ];
    defaultJDK = builtins.elemAt installedJDKs 0;
    projDir = "${config.xdg.userDirs.extraConfig.WORKSPACE}/spreadconfig";
    scriptsDir = "${config.home.homeDirectory}/scripts";
    secretsDir = "${projDir}/secrets";
    spreadconfigDir = "${projDir}/spreadconfig";
    mochaBg = "0e1117";
    theme_tranparent = "00000000";
    theme_background = "000000";
    theme_red = "bc3f3c";
    theme_green = "6a9955";
    theme_yellow = "e6e6aa";
    theme_blue = "47a2ed";
    theme_purple = "3181a7";
    theme_magenta = "bc3f3c";
    theme_cyan = "47ccb1";
    theme_white = "d4d4d4";
    theme_bright_background = "3a3a3a";
    theme_bright_dark = "72737a";
    theme_bright_red = "ff0000";
    theme_bright_blue = "8cd7ff";
    theme_bright_white = "ffffff";
    theme_bright_yellow = "ffc66d";
    theme_radius = "0";
in
{
    imports = [
        inputs.nixvim.homeModules.nixvim
    ];
    home = {
        username = "spreadzhao";
        homeDirectory = "/home/spreadzhao";
        stateVersion = "25.11";
        sessionVariables = {
            SCRIPT_HOME = scriptsDir;
            QT_QPA_PLATFORM = "wayland";
            QT_ENABLE_HIGHDPI_SCALING = "1";
            PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
            STARSHIP_CONFIG = "${config.xdg.configHome}/starship/starship.toml";
            TERMINAL = "foot";
            TERM = "foot";
        };
        shell.enableShellIntegration = true;
        sessionPath = [
            "$SCRIPT_HOME/util/bin"
            "$SCRIPT_HOME/nix"
            "$HOME/.local/bin"
            "$HOME/.cargo/bin"
            "$HOME/go/bin"
            "$HOME/Android/Sdk/platform-tools"
            "$HOME/Lib/jdks/bin"
            "$HOME/.npm/bin"
        ];
        file = {
            "${scriptsDir}".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/scripts";
            ".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/Jetbrains/.ideavimrc";
        }
        # jdk
        // (builtins.listToAttrs (
            map (jdk: {
                name = "${config.xdg.userDirs.extraConfig.LIB}/jdks/${jdk.version}";
                value = {
                    source = jdk;
                };
            }) installedJDKs
        ));
        pointerCursor = {
            enable = true;
            name = "Adwaita";
            size = 36;
            package = pkgs.adwaita-icon-theme;
            gtk.enable = true;
            x11.enable = true;
            dotIcons.enable = true;
            hyprcursor = {
                enable = false;
                size = 36;
            };
        };
        packages = with pkgs; [
            # zsh plugin
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-completions
            zsh-fzf-tab

            # dev
            gcc
            gdb
            gnumake
            cmake
            ninja
            # clang and gcc both offer `ld`, we use clang here
            (lib.hiPrio clang)
            clang-tools
            lldb
            cargo
            rustc
            # rustup no need
            python3
            go
            jetbrains-toolbox
            jadx
            ghidra-bin

            # language-server
            bash-language-server
            gopls
            lua-language-server
            nixd
            rust-analyzer

            # formatters
            cmake-format
            nixfmt
            rustfmt
            shfmt
            stylua
            xmlstarlet

            # media: pic, music, video
            imagemagick
            mpv
            (feh.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/feh.desktop \
                      --replace-fail "Exec=feh --start-at %u" \
                                     "Exec=feh --theme fit --start-at %u"
                '';
            }))
            satty
            # libsixel
            wf-recorder
            chafa
            ffmpeg
            ffmpegthumbnailer
            # screenshot
            grim
            slurp
            wayfreeze
            (scrcpy.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/scrcpy.desktop \
                      --replace-fail "-c scrcpy\"" \
                                     "-c 'scrcpy --render-driver=opengl'\""
                    rm $out/share/applications/scrcpy-console.desktop
                '';
            }))

            # document
            zathura
            obsidian

            # util
            starship
            fastfetch
            onefetch
            tealdeer
            nix-tree
            gdu
            bluetui
            eza
            bat
            duf
            dust
            diff-so-fancy
            xeyes
            qrencode

            # compress
            rar
            unzip
            zip
            p7zip

            wechat
            (qq.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/qq.desktop \
                      --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
                '';
            }))
            (
                (qutebrowser.overrideAttrs (old: {
                    postInstall = (old.postInstall or "") + ''
                        substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
                          --replace-fail "Exec=qutebrowser" "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser"
                    '';
                })).override
                {
                    enableWideVine = true;
                }
            )

            # niri and it's dependencies
            niri
            xwayland-satellite
            waybar
            libnotify
            wl-clipboard
            pastel
            telegram-desktop
            pass
            wbg

            # fonts
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            nerd-fonts.symbols-only
            ibm-plex

            tesseract
            poppler-utils
            lf
            trash-cli
            rsync
            rclone
            lazygit
            wooz
        ];
    };
    systemd.user.services = {
        # https://wiki.nixos.org/wiki/Polkit#Using_Home_Manager
        polkit-gnome-authentication-agent-1 = {
            Unit = {
                Description = "polkit-gnome-authentication-agent-1";
                Wants = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
            };
            Install = {
                WantedBy = [ "graphical-session.target" ];
            };
            Service = {
                Type = "simple";
                ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
            };
        };
        niri = {
            Unit = {
                Description = "A scrollable-tilling Wayland compositor";
                BindsTo = [ "graphical-session.target" ];
                Before = [
                    "graphical-session.target"
                    "xdg-desktop-autostart.target"
                ];
                After = [ "graphical-session-pre.target" ];
                Wants = [
                    "graphical-session-pre.target"
                    "xdg-desktop-autostart.target"
                    "waybar.service"
                ];
            };
            Service = {
                Slice = "session.slice";
                Type = "notify";
                ExecStart = "${pkgs.niri}/bin/niri --session";
            };
        };
        niri-window-detect = {
            Unit = {
                Description = "Niri window change watcher";
                After = [
                    "niri.service"
                ];
                BindsTo = [
                    "niri.service"
                ];
                PartOf = [
                    "niri.service"
                ];
            };
            Service = {
                ExecStart = "${scriptsDir}/niri/detect_niri_window_change.sh";
                Restart = "always";
                RestartSec = 2;
                StandardOutput = "journal";
                StandardError = "journal";
            };
            Install = {
                WantedBy = [
                    "graphical-session.target"
                ];
            };
        };
        file-manager-dbus = {
            Unit = {
                Description = "Use terminal to open files";
                After = [
                    "niri.service"
                ];
                BindsTo = [
                    "niri.service"
                ];
                PartOf = [
                    "niri.service"
                ];
            };
            Service = {
                ExecStart = "${config.xdg.userDirs.extraConfig.APP}/file_manager_dbus";
                Restart = "on-failure";
                RestartSec = 5;
                TimeoutStopSec = 10;
            };
            Install = {
                WantedBy = [
                    "graphical-session.target"
                    "niri.service"
                ];
            };
        };
        # wbg = {
        #     Unit = {
        #         Description = "Wallpaper";
        #         PartOf = [ "niri.service" ];
        #         After = [ "niri.service" ];
        #         Requisite = [ "niri.service" ];
        #     };
        #     Service = {
        #         ExecStart = "${scriptsDir}/util/random_wallpaper_apply.sh";
        #         Restart = "no";
        #     };
        #     Install = {
        #         WantedBy = [
        #             "graphical-session.target"
        #             "niri.service"
        #         ];
        #     };
        # };
    };
    xdg = {
        enable = true;
        autostart = {
            enable = true;
            readOnly = true;
        };
        configFile = {
            # "niri".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/niri";
            "niri/config.kdl".text = ''
                animations {
                    off
                }

                gestures {
                    hot-corners {
                        off
                    }
                }

                input {
                    keyboard {
                        numlock
                    }

                    touchpad {
                        // tap
                        dwt
                        natural-scroll
                        accel-speed 0.5
                        scroll-factor 0.5
                    }

                }

                layout {
                    gaps 4
                    background-color "#${theme_background}"
                    center-focused-column "never"
                    preset-column-widths {
                        proportion 0.5
                        proportion 1.0
                    }
                    preset-window-heights {
                        proportion 0.33333
                        proportion 0.5
                        proportion 0.66667
                        proportion 1.0
                    }
                    default-column-width { proportion 0.5; }
                    focus-ring {
                        // off
                        width 2
                        active-color "#${theme_bright_white}"
                        inactive-color "#${theme_bright_dark}"
                    }
                    tab-indicator {
                        // hide-when-single-tab
                        place-within-column
                        gap 4
                        width 4
                        corner-radius ${theme_radius}
                        length total-proportion=1.0
                        position "left"
                        gaps-between-tabs 4
                        active-color "#${theme_bright_yellow}"
                        inactive-color "#${theme_bright_dark}"
                        urgent-color "#${theme_bright_red}"
                    }
                    struts {
                        left -2
                        right -2
                        top -2
                        bottom -2
                    }
                }

                output "eDP-1" {
                    // off
                    scale 2
                    position x=5360 y=500
                    // position x=3440 y=1439          // ensure monitor has left/right relationship
                    layout {
                        default-column-width { proportion 1.0; }
                        preset-column-widths {
                            proportion 0.5
                            proportion 1.0
                        }
                    }
                }

                output "HDMI-A-1" {
                    scale 1
                    position x=0 y=0
                    layout {
                        default-column-width { proportion 0.5; }
                        preset-column-widths {
                            proportion 0.5
                            proportion 1.0
                        }
                    }
                }

                output "DP-2" {
                    scale 1
                    position x=3440 y=180
                    focus-at-startup
                    layout {
                        default-column-width { proportion 1.0; }
                        preset-column-widths {
                            proportion 0.5
                            proportion 1.0
                        }
                    }
                }

                environment {
                    // GTK_IM_MODULE "fcitx"
                    // QT_QPA_PLATFORM "wayland"
                    // ELECTRON_OZONE_PLATFORM_HINT "auto"
                }

                recent-windows {
                    debounce-ms 750

                    open-delay-ms 150

                    highlight {
                        active-color "#${theme_bright_dark}"
                        urgent-color "#${theme_bright_red}"
                        padding 30
                        corner-radius ${theme_radius}
                    }

                    previews {
                        max-height 480
                        max-scale 0.5
                    }

                    binds {
                        Mod+Tab         { next-window; }
                        Mod+Shift+Tab   { previous-window; }
                        Mod+grave       { next-window     filter="app-id"; }
                        Mod+Shift+grave { previous-window filter="app-id"; }
                    }
                }

                overview {
                    backdrop-color "#${theme_background}"
                }

                hotkey-overlay {
                    skip-at-startup
                }

                prefer-no-csd

                screenshot-path null

                cursor {
                    xcursor-theme "Adwaita"
                    xcursor-size 36
                    hide-after-inactive-ms 5000
                }

                clipboard {
                    disable-primary
                }

                // layer-rule {
                //     match namespace="^launcher$"
                //     shadow {
                //         on
                //         softness 15
                //         spread 1
                //         offset x=0 y=0
                //         draw-behind-window false
                //         color "#f2cdcd"
                //     }
                //     geometry-corner-radius 8
                // }

                // window-rule {
                //     geometry-corner-radius 8
                //     clip-to-geometry true
                //     draw-border-with-background false
                // }

                window-rule {
                    match is-floating=false
                    tiled-state true
                }

                // window-rule {
                //     match is-focused=true
                //     shadow {
                //         on
                //         softness 15
                //         spread 1
                //         offset x=0 y=0
                //         draw-behind-window false
                //         color "#f2cdcd"
                //     }
                // }

                window-rule {
                    match app-id="feh"
                    match app-id="org.qutebrowser.qutebrowser"
                    open-fullscreen false
                }

                window-rule {
                    match app-id="feh" title=".*\/tmp.*"
                    match app-id=".*jetbrains.*" title=".*Welcome.*"
                    match app-id="com.gabm.satty"
                    open-floating true
                    open-fullscreen false
                }

                // wechat bug for some floating windows
                window-rule {
                    match app-id="wechat" title="wechat"
                    open-focused false
                }

                // Indicate screencasted windows with red colors.
                window-rule {
                    match is-window-cast-target=true

                    focus-ring {
                        active-color "#${theme_blue}"
                        inactive-color "#${theme_bright_blue}"
                        width 2
                    }
                }

                // floating terminal
                window-rule {
                    match app-id="lick-foot"
                    open-floating true
                    default-column-width { proportion 0.75; }
                    default-window-height { proportion 0.6; }
                }

                binds {
                    Mod+Shift+Slash { show-hotkey-overlay; }

                    Mod+Return hotkey-overlay-title="Open a Terminal" { spawn-sh "footclient"; }
                    Mod+space hotkey-overlay-title="Run an Application" { spawn "fuzzel"; }
                    // Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }

                    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+ && pkill -RTMIN+7 waybar"; }
                    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_SINK@ 5%- && pkill -RTMIN+7 waybar"; }
                    XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && pkill -RTMIN+7 waybar"; }
                    XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && pkill -RTMIN+7 waybar"; }

                    XF86MonBrightnessUp allow-when-locked=true { spawn-sh "brightnessctl --class=backlight set +10%"; }
                    XF86MonBrightnessDown allow-when-locked=true { spawn-sh "brightnessctl --class=backlight set 10%-"; }

                    Mod+D { spawn-sh "swaylock"; }
                    Mod+Shift+D { spawn-sh "$SCRIPT_HOME/niri/niri_lock.sh"; }

                    Mod+B { spawn-sh "killall -SIGUSR1 .waybar-wrapped"; }

                    Mod+O repeat=false { toggle-overview; }

                    Mod+Shift+C repeat=false { close-window; }

                    Mod+Left  { focus-column-or-monitor-left; }
                    Mod+Down  { focus-window-or-monitor-down; }
                    Mod+Up    { focus-window-or-monitor-up; }
                    Mod+Right { focus-column-or-monitor-right; }
                    Mod+H     { focus-column-or-monitor-left; }
                    Mod+J     { focus-window-or-monitor-down; }
                    Mod+K     { focus-window-or-monitor-up; }
                    Mod+L     { focus-column-or-monitor-right; }

                    Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
                    Mod+Shift+Down  { move-window-down-or-to-workspace-down; }
                    Mod+Shift+Up    { move-window-up-or-to-workspace-up; }
                    Mod+Shift+Right { move-column-right-or-to-monitor-right; }
                    Mod+Shift+H     { move-column-left-or-to-monitor-left; }
                    Mod+Shift+J     { move-window-down-or-to-workspace-down; }
                    Mod+Shift+K     { move-window-up-or-to-workspace-up; }
                    Mod+Shift+L     { move-column-right-or-to-monitor-right; }

                    Mod+Home { focus-column-first; }
                    Mod+End  { focus-column-last; }
                    Mod+Shift+Home { move-column-to-first; }
                    Mod+Shift+End  { move-column-to-last; }

                    Mod+Ctrl+Left  { focus-monitor-left; }
                    Mod+Ctrl+Down  { focus-monitor-down; }
                    Mod+Ctrl+Up    { focus-monitor-up; }
                    Mod+Ctrl+Right { focus-monitor-right; }
                    Mod+Ctrl+H     { focus-monitor-left; }
                    Mod+Ctrl+J     { focus-monitor-down; }
                    Mod+Ctrl+K     { focus-monitor-up; }
                    Mod+Ctrl+L     { focus-monitor-right; }

                    Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
                    Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
                    Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
                    Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
                    Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
                    Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
                    Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
                    Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

                    Mod+Alt+P   { move-workspace-up; }
                    Mod+Alt+N   { move-workspace-down; }
                    Mod+Alt+L   { move-workspace-to-monitor-right; }
                    Mod+Alt+H   { move-workspace-to-monitor-left; }

                    Mod+N              { focus-workspace-down; }
                    Mod+P              { focus-workspace-up; }
                    Mod+Shift+N         { move-column-to-workspace-down; }
                    Mod+Shift+P         { move-column-to-workspace-up; }
                    Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
                    Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
                    Mod+WheelScrollRight                { focus-column-or-monitor-right; }
                    Mod+WheelScrollLeft                 { focus-column-or-monitor-left; }

                    Mod+1 { focus-workspace 1; }
                    Mod+2 { focus-workspace 2; }
                    Mod+3 { focus-workspace 3; }
                    Mod+4 { focus-workspace 4; }
                    Mod+5 { focus-workspace 5; }
                    Mod+6 { focus-workspace 6; }
                    Mod+7 { focus-workspace 7; }
                    Mod+8 { focus-workspace 8; }
                    Mod+9 { focus-workspace 9; }
                    Mod+Shift+1 { move-column-to-workspace 1; }
                    Mod+Shift+2 { move-column-to-workspace 2; }
                    Mod+Shift+3 { move-column-to-workspace 3; }
                    Mod+Shift+4 { move-column-to-workspace 4; }
                    Mod+Shift+5 { move-column-to-workspace 5; }
                    Mod+Shift+6 { move-column-to-workspace 6; }
                    Mod+Shift+7 { move-column-to-workspace 7; }
                    Mod+Shift+8 { move-column-to-workspace 8; }
                    Mod+Shift+9 { move-column-to-workspace 9; }

                    // Mod+Tab { focus-window-previous; }
                    // Mod+Shift+Tab { focus-workspace-previous; }

                    Mod+Shift+Comma  { consume-or-expel-window-left; }
                    Mod+Shift+Period { consume-or-expel-window-right; }

                    Mod+Comma  { consume-window-into-column; }
                    Mod+Period { expel-window-from-column; }

                    Mod+R { switch-preset-column-width; }
                    Mod+Shift+R { switch-preset-window-height; }
                    Mod+Ctrl+R { reset-window-height; }
                    Mod+F { maximize-column; }
                    Mod+M { fullscreen-window; }
                    Mod+Shift+M { toggle-windowed-fullscreen; }

                    Mod+C { center-column; }

                    Mod+Minus { set-column-width "-10%"; }
                    Mod+Equal { set-column-width "+10%"; }

                    Mod+Shift+Minus { set-window-height "-10%"; }
                    Mod+Shift+Equal { set-window-height "+10%"; }
                    Mod+Ctrl+Equal { expand-column-to-available-width; }

                    Mod+Shift+F       { toggle-window-floating; }
                    Mod+Ctrl+F { switch-focus-between-floating-and-tiling; }

                    Mod+T { toggle-column-tabbed-display; }

                    Ctrl+Shift+A { spawn-sh "$SCRIPT_HOME/niri/screenshot.sh";  }
                    Ctrl+Shift+S { spawn-sh "$SCRIPT_HOME/niri/screenrecord.sh";  }

                    Mod+Shift+V { spawn-sh "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

                    Mod+Z { spawn-sh "wooz --invert-scroll --output $($SCRIPT_HOME/niri/niri_focused_output_name.sh)"; }
                    Mod+S { spawn-sh "slurp -b '#${theme_background}aa' -c '#${theme_bright_white}' >/dev/null"; }

                    Mod+W { spawn-sh "$SCRIPT_HOME/util/toggle_wallpaper.sh"; }

                    Mod+Shift+Q { quit; }
                }
            '';
            "foot".enable = false;
            "foot".force = true;
            "foot".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/foot";
            "waybar".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/waybar";
            "starship".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/starship";
            # "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/swaylock";
            "obs-studio/basic/profiles/Video".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Video";
            "obs-studio/basic/profiles/Audio".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Audio";
            "qutebrowser/quickmarks".source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/qutebrowser_quickmarks";
            "qutebrowser/config.py".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/qutebrowser/config.py";
            "qutebrowser/themes".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/qutebrowser/themes";
            "gdu".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/gdu";
            "lf".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/lf";
            "bat".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/bat";
            # "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/fuzzel";
            "lazygit".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/lazygit";
            "xdg-desktop-portal-termfilechooser".source =
                config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/xdg-desktop-portal-termfilechooser";
            "feh".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/feh";
            "satty".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/satty";
            # "mpv".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/mpv";
            "zathura".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/zathura";
            # https://github.com/boydaihungst/org.freedesktop.FileManager1.common
            "org.freedesktop.FileManager1.common/config".text = ''
                cmd="${scriptsDir}/util/lf-wrapper-dbus.sh"
            '';
            # service
            "systemd/user/waybar.service".source = "${pkgs.waybar}/share/systemd/user/waybar.service";
        };
        dataFile = {
            "fcitx5/rime/rime-data".source = "${pkgs.rime-ice}/share/rime-data";
            "fcitx5/rime/default.custom.yaml".source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/default";
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
    dconf = {
        enable = true;
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
            };
        };
    };
    gtk = {
        enable = true;
        colorScheme = "dark";
        # theme = {
        #     name = "catppuccin-mocha-rosewater-compact+default";
        #     package =
        #         (pkgs.catppuccin-gtk.overrideAttrs {
        #             src = pkgs.fetchFromGitHub {
        #                 owner = "catppuccin";
        #                 repo = "gtk";
        #                 rev = "v1.0.3";
        #                 fetchSubmodules = true;
        #                 hash = "sha256-q5/VcFsm3vNEw55zq/vcM11eo456SYE5TQA3g2VQjGc=";
        #             };
        #
        #             postUnpack = "";
        #         }).override
        #             {
        #                 accents = [ "rosewater" ];
        #                 variant = "mocha";
        #                 size = "compact";
        #             };
        # };
        cursorTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
            size = 36;
        };
        font = {
            # name = "Noto Sans";
            name = "IBM Plex Sans";
            size = 16;
        };
        gtk3 = {
            enable = true;
        };
        gtk4.enable = true;
    };
    qt = {
        enable = true;
        platformTheme.name = "xdgdesktopportal";
        style = {
            package = pkgs.adwaita-qt;
            name = "adwaita-dark";
        };
        qt5ctSettings = {
            Appearance = {
                standar_dialogs = "xdgdesktopportal";
            };
            Fonts = {
                fixed = "\"IBM Plex Mono,16\"";
                general = "\"IBM Plex Sans,16\"";
            };
        };
        qt6ctSettings = {
            Appearance = {
                standar_dialogs = "xdgdesktopportal";
            };
            Fonts = {
                fixed = "\"IBM Plex Mono,16\"";
                general = "\"IBM Plex Sans,16\"";
            };
        };
    };
    programs = {
        fuzzel = {
            enable = true;
            settings = {
                border = {
                    radius = "${theme_radius}";
                };
                colors = {
                    background = "${theme_background}dd";
                    text = "${theme_bright_white}ff";
                    prompt = "${theme_bright_white}ff";
                    placeholder = "${theme_bright_dark}ff";
                    input = "${theme_bright_white}ff";
                    match = "${theme_yellow}ff";
                    selection = "${theme_bright_background}ff";
                    selection-text = "${theme_bright_white}ff";
                    selection-match = "${theme_yellow}ff";
                    counter = "${theme_blue}ff";
                };
                main = {
                    font = "IBM Plex Mono:size=18, Symbols Nerd Font Mono:size=18, Noto Color Emoji:size=18";
                    image-size-ratio = 1;
                    show-actions = "no";
                    tabs = 4;
                    terminal = "footclient -a '{cmd}' -T '{cmd}' {cmd}";
                    use-bold = "yes";
                    width = 50;
                };
                key-bindings = {
                    "next" = "none";
                    "prev" = "none";
                    next-with-wrap = "Control+n";
                    prev-with-wrap = "Control+p";
                };
            };
        };
        swaylock = {
            enable = true;
            settings = {
                ignore-empty-password = true;
                show-failed-attempts = true;
                daemonize = true;

                font = "IBM Plex Sans";
                font-size = 30;

                color = "${theme_background}";

                inside-color = "${theme_tranparent}";
                inside-clear-color = "${theme_tranparent}";
                inside-caps-lock-color = "${theme_tranparent}";
                inside-ver-color = "${theme_tranparent}";
                inside-wrong-color = "${theme_tranparent}";

                line-color = "${theme_tranparent}";
                line-clear-color = "${theme_tranparent}";
                line-caps-lock-color = "${theme_tranparent}";
                line-ver-color = "${theme_tranparent}";
                line-wrong-color = "${theme_tranparent}";

                separator-color = "${theme_tranparent}";
                layout-bg-color = "${theme_tranparent}";
                layout-border-color = "${theme_tranparent}";

                # ===============================
                # Ring
                # ===============================

                ring-color = "${theme_bright_dark}"; # 默认：冷灰
                ring-clear-color = "${theme_blue}"; # 输入中：蓝
                ring-caps-lock-color = "${theme_bright_yellow}";
                ring-ver-color = "${theme_cyan}"; # 验证中：青
                ring-wrong-color = "${theme_bright_red}"; # 错误：亮红

                # ===============================
                # Text
                # ===============================

                text-color = "${theme_white}";
                text-clear-color = "${theme_blue}";
                text-caps-lock-color = "${theme_bright_yellow}";
                text-ver-color = "${theme_cyan}";
                text-wrong-color = "${theme_bright_red}";

                layout-text-color = "${theme_white}";

                # ===============================
                # Key feedback（低调处理）
                # ===============================

                key-hl-color = "${theme_white}";
                caps-lock-key-hl-color = "${theme_bright_white}";
                bs-hl-color = "${theme_blue}";
                caps-lock-bs-hl-color = "${theme_bright_yellow}";

                scaling = "fit";

                indicator-radius = 200;
                indicator-idle-visible = true;

                disable-caps-lock-text = true;
                indicator-caps-lock = true;
            };
        };
        foot = {
            enable = true;
            server.enable = true;
            settings = {
                main = {
                    font = "IBM Plex Mono:size=16, Symbols Nerd Font Mono:size=16";
                    bold-text-in-bright = "yes";
                };
                colors = {
                    alpha = 0.8;

                    foreground = "ffffff";
                    background = "000000";
                    cursor = "171616 adaeac";

                    # --- ANSI 8 colors ---

                    regular0 = "${theme_background}"; # black (background)
                    regular1 = "${theme_red}"; # red (error)
                    regular2 = "${theme_green}"; # green (comment)
                    regular3 = "${theme_yellow}"; # yellow (function)
                    regular4 = "${theme_blue}"; # blue (keyword)
                    regular5 = "${theme_magenta}"; # magenta (secondary keyword)
                    regular6 = "${theme_cyan}"; # cyan (class)
                    regular7 = "${theme_white}"; # white (default text)

                    # --- bright variants ---

                    bright0 = "${theme_bright_dark}";
                    bright1 = "ff6b6b";
                    bright2 = "b4cda8";
                    bright3 = "d7ba7d";
                    bright4 = "${theme_bright_blue}";
                    bright5 = "e49ad8";
                    bright6 = "5fe0c6";
                    bright7 = "ffffff";

                    selection-foreground = "adaeac";
                    selection-background = "264e77";

                    search-box-no-match = "171616 f44747";
                    search-box-match = "adaeac 262626";

                    jump-labels = "171616 e6e6aa";
                    urls = "47a2ed";
                };
                cursor = {
                    style = "beam";
                };
                desktop-notifications = {
                    command = ''notify-send --wait --app-name ''\${app-id} --icon ''\${app-id} --category ''\${category} --urgency ''\${urgency} --expire-time ''\${expire-time} --hint STRING:image-path:''\${icon} --hint BOOLEAN:suppress-sound:''\${muted} --hint STRING:sound-name:''\${sound-name} --replace-id ''\${replace-id} ''\${action-argument} --print-id -- ''\${title} ''\${body}'';
                };
                url = {
                    launch = "xdg-open ''\${url}";
                };
                key-bindings = {
                    scrollback-up-half-page = "Control+u";

                    scrollback-down-half-page = "Control+d";
                    search-start = "Control+f";
                };
                search-bindings = {
                    find-prev = "Control+p";
                    find-next = "Control+n";
                };
            };
        };
        npm = {
            enable = true;
            settings = {
                prefix = "${config.home.homeDirectory}/.npm";
                color = true;
            };
        };
        btop = {
            enable = true;
            settings = {
                theme_background = false;
                truecolor = true;
                vim_keys = true;
            };
        };
        java = {
            enable = true;
            package = defaultJDK;
        };
        git = {
            enable = true;
            settings = {
                user = {
                    name = "SpreadZhao";
                    email = "spreadzhao@outlook.com";
                };
                core = {
                    editor = "nvim";
                };
            };
        };
        gh = {
            enable = true;
            settings = {
                git_protocol = "https";
                prompt = "enabled";
                aliases = {
                    co = "pr checkout";
                };
            };
            hosts = {
                "github.com" = {
                    user = "SpreadZhao";
                    oauth_token = lib.strings.trim (builtins.readFile ./secrets/gh_token);
                    git_protocol = "https";
                };
            };
        };
        obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
                obs-backgroundremoval
                obs-pipewire-audio-capture
                obs-vaapi
            ];
        };
        zsh = {
            enable = true;
            enableCompletion = false;
            defaultKeymap = "viins";
            dotDir = "${config.xdg.configHome}/zsh";
            history = {
                append = true;
                extended = true;
                findNoDups = true;
                share = true;
                save = 10000;
                size = 10000;
            };
            shellAliases = {
                cat = "bat";
                df = "duf";
                du = "dust";
                cd = "z";
                rm = "rm -Iv";
                ls = "eza --icons";
                ll = "eza -l --git --icons";
                la = "eza -la --git --icons";
                l = "eza -lah --git --icons";
                n = "nvim .";
                lg = "lazygit";
                c = "clear";
                wk = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}";
                sb = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SecondBrain";
                st = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SpreadStudy";
                lc = "cd ${config.xdg.userDirs.extraConfig.WORKSPACE}/SpreadStudy/Leetcode/LeetcodeCpp/ && n";
                shuffle = "mpv --shuffle --force-window --autofit-smaller=800x500 .";
                q = "exit";
                ca = "mpv /dev/video0";
                feh = "feh --theme fit";
                cdgvfs = "cd /run/user/$(id -u)/gvfs";
                se = "sudo -E nvim";
                sf = "cd ~/workspaces/spreadconfig";
                mv = "mv -iv";
                cp = "cp -iv";
                mkdir = "mkdir -v";
                onefetch = "onefetch -T programming markup prose data";
                lf = "lfcd";
                ff = "${scriptsDir}/niri/start_floating_foot.sh";
                ts = "gio trash";
                rsync = "rsync --progress";
                slurp = "slurp -b #0e1117aa -c #f5e0dc";
            };
            shellGlobalAliases = {
            };
            initContent = lib.mkOrder 2000 ''
                source ${scriptsDir}/config/config_zsh_nix.sh
                source ${scriptsDir}/config/color_output.sh
                eval "$(starship init zsh)"

                lfcd () {
                    # `command` is needed in case `lfcd` is aliased to `lf`
                    cd "$(command lf -print-last-dir "$@")"
                }

                function vi-yank-wlclip {
                    zle vi-yank
                    print -rn -- "$CUTBUFFER" | wl-copy
                }

                zle -N vi-yank-wlclip
                bindkey -M vicmd 'y' vi-yank-wlclip

                # plugins
                source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
                source ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
                source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
            '';
        };
        zoxide.enable = true;
        fd = {
            enable = true;
            extraOptions = [
                "--no-ignore"
                "--absolute-path"
            ];
            ignores = [
                ".git/"
            ];
        };
        fzf = {
            enable = true;
            changeDirWidgetCommand = "fd --type d";
            changeDirWidgetOptions = [
                "--preview 'eza --tree --color=always {} | head -200'"
            ];
            defaultCommand = "fd --type f";
            fileWidgetCommand = "fd --type f";
            fileWidgetOptions = [
                "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
            ];
            historyWidgetOptions = [
                "--sort"
                "--exact"
            ];
        };
        nixvim = {
            enable = true;
            defaultEditor = true;
            globals = {
                mapleader = " ";
                maplocalleader = " ";
                have_nerd_font = true;
                loaded_netrw = 1;
                loaded_netrwPlugin = 1;
            };
            opts = {
                number = true;
                relativenumber = true;
                mouse = "a";
                showmode = false;
                clipboard = "unnamedplus";
                breakindent = true;
                undofile = true;
                shiftwidth = 4;
                tabstop = 4;
                expandtab = true;
                autoindent = true;
                ignorecase = true;
                smartcase = true;
                signcolumn = "yes";
                updatetime = 250;
                timeoutlen = 300;
                splitright = true;
                splitbelow = true;
                list = true;
                cursorline = true;
                scrolloff = 10;
                confirm = true;
                wrap = false;
                termguicolors = true;
                background = "dark";
                # foldenable = false;
                foldlevelstart = 99;
            };
            autoGroups = {
                "highlight-yank" = {
                    clear = true;
                };
            };
            autoCmd = [
                {
                    event = "TextYankPost";
                    group = "highlight-yank";
                    callback.__raw = ''
                        function()
                          vim.hl.on_yank()
                        end
                    '';
                }
            ];
            highlightOverride = {
                LineNrAbove.fg = "#a6adc8";
                LineNrBelow.fg = "#a6adc8";
            };
            keymaps = [
                {
                    key = "'";
                    action = "$";
                    mode = [
                        "n"
                        "v"
                    ];
                }
                {
                    key = "<Esc>";
                    action = "<CMD>nohlsearch<CR>";
                    mode = "n";
                }
                {
                    key = "<C-h>";
                    action = "<C-w><C-h>";
                    mode = "n";
                }
                {
                    key = "<C-l>";
                    action = "<C-w><C-l>";
                    mode = "n";
                }
                {
                    key = "<C-j>";
                    action = "<C-w><C-j>";
                    mode = "n";
                }
                {
                    key = "<C-k>";
                    action = "<C-w><C-k>";
                    mode = "n";
                }
                {
                    key = "gk";
                    action = "<C-o>";
                    mode = "n";
                    options = {
                        desc = "go back";
                        noremap = true;
                    };
                }
                {
                    key = "gj";
                    action = "<C-i>";
                    mode = "n";
                    options = {
                        desc = "go forward";
                        noremap = true;
                    };
                }
                {
                    key = "/";
                    mode = "v";
                    action = ''""y/\V<C-R>=escape(@", '/\')<CR><CR>'';
                    options = {
                        desc = "Search Visual Selection";
                    };
                }
                {
                    key = "<leader>fs";
                    action = "<CMD>Oil<CR>";
                    mode = "n";
                    options = {
                        desc = "File System";
                    };
                }
                {
                    key = "<leader>nt";
                    action = "<CMD>tabnew<CR><CMD>Oil<CR>";
                    mode = "n";
                    options = {
                        desc = "New Tab";
                    };
                }
                {
                    key = "<leader>lg";
                    action = "<CMD>LazyGit<CR>";
                    mode = "n";
                    options = {
                        desc = "LazyGit";
                    };
                }
                {
                    key = "<leader>;";
                    action.__raw = ''
                        function()
                            require('flash').jump()
                        end
                    '';
                    mode = "n";
                    options.desc = "Jump Code";
                }
                {
                    key = "<leader>ff";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').files()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Files";
                    };
                }
                {
                    key = "<leader>ge";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').buffers()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Buffers";
                    };
                }
                {
                    key = "<leader>fh";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').oldfiles()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find History";
                    };
                }
                {
                    key = "<leader>ft";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').tabs()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Tab";
                    };
                }
                {
                    key = "<leader>fk";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').keymaps()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Keymaps";
                    };
                }
                {
                    key = "<leader>fe";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').live_grep({ resume = true })
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Everything";
                    };
                }
                {
                    key = "<leader>?";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').helptags()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Find Helps";
                    };
                }
                {
                    key = "<leader>fe";
                    action = {
                        __raw = ''
                            function()
                                require('fzf-lua').grep_visual()
                            end
                        '';
                    };
                    mode = "v";
                    options = {
                        desc = "Find Under Cursor";
                    };
                }
                {
                    key = "<leader>tt";
                    action = "<CMD>ToggleTerm<CR>";
                    mode = "n";
                    options = {
                        desc = "Toggle Term";
                        noremap = true;
                    };
                }
                {
                    key = "<leader>ot";
                    action = "<CMD>Outline<CR>";
                    mode = "n";
                    options = {
                        desc = "Toggle Outline";
                        noremap = true;
                    };
                }
                {
                    key = "<leader>of";
                    action = "<CMD>OutlineFocus<CR>";
                    mode = "n";
                    options = {
                        desc = "Focus Outline";
                        noremap = true;
                    };
                }
            ];
            colorscheme = "vscode";
            colorschemes = {
                vscode = {
                    enable = true;
                    settings = {
                        transparent = true;
                        italic_comments = false; # JetBrains 默认不斜体
                        italic_inlayhints = true;
                        underline_links = true;
                        disable_nvimtree_bg = true;
                        terminal_colors = true;

                        color_overrides = {
                            vscBack = "#000000";
                            vscLineNumber = "#7C7C7C";
                            vscCursorDarkDark = "#262626";
                            vscSelection = "#262626";
                            vscForeground = "#ADAEAC";
                        };

                        group_overrides = {
                            # ===== 注释 =====
                            Comment = {
                                fg = "#6A9955";
                                italic = false;
                            };

                            # ===== 关键字 =====
                            Keyword = {
                                fg = "#47A2ED";
                            };

                            # ===== static =====
                            StorageClass = {
                                fg = "#FFC66D";
                            };

                            # ===== 类 =====
                            Type = {
                                fg = "#47CCB1";
                            };

                            # ===== 类成员 =====
                            Field = {
                                fg = "#47CCB1";
                            };

                            Property = {
                                fg = "#47CCB1";
                            };

                            # ===== 函数 =====
                            Function = {
                                fg = "#E6E6AA";
                            };

                            # ===== 错误 =====
                            DiagnosticError = {
                                fg = "#F44747";
                                bold = true;
                            };

                            # ===== 字符串 =====
                            String = {
                                fg = "#CD9069";
                            };

                            # ===== 常量 =====
                            Constant = {
                                fg = "#FFC66D";
                            };
                        };
                    };
                };
                catppuccin = {
                    enable = false;
                    lazyLoad.enable = true;
                    settings = {
                        transparent_background = true;
                        flavour = "mocha";
                        dim_inactive = {
                            enabled = false;
                            shade = "dark";
                            percentage = 0.15;
                        };
                        show_end_of_buffer = false;
                        term_colors = true;
                        styles = {
                            comments = [ "italic" ];
                            functions = [ "bold" ];
                            keywords = [ "italic" ];
                            operators = [ "bold" ];
                            conditionals = [ "bold" ];
                            loops = [ "bold" ];
                            booleans = [
                                "bold"
                                "italic"
                            ];
                        };
                        integrations = {
                            cmp = true;
                            dap = true;
                            dap_ui = true;
                            diffview = true;
                            dropbar = {
                                enabled = true;
                                color_mode = true;
                            };
                            fidget = true;
                            flash = true;
                            fzf = true;
                            gitsigns = true;
                            grug_far = true;
                            hop = true;
                            indent_blankline = {
                                enabled = true;
                                colored_indent_levels = true;
                            };
                            lsp_saga = true;
                            lsp_trouble = true;
                            markdown = true;
                            mason = true;
                            mini = {
                                enabled = true;
                            };
                            native_lsp = {
                                enabled = true;
                                virtual_text = {
                                    errors = [ "italic" ];
                                    hints = [ "italic" ];
                                    warnings = [ "italic" ];
                                    information = [ "italic" ];
                                };
                                underlines = {
                                    errors = [ "underline" ];
                                    hints = [ "underline" ];
                                    warnings = [ "underline" ];
                                    information = [ "underline" ];
                                };
                            };
                            notify = true;
                            nvimtree = true;
                            rainbow_delimiters = true;
                            render_markdown = true;
                            semantic_tokens = true;
                            telescope = {
                                enabled = true;
                                style = "nvchad";
                            };
                            treesitter = true;
                            treesitter_context = true;
                            which_key = true;
                        };
                        color_overrides = {
                            mocha = {
                                base = "#${mochaBg}";
                            };
                        };
                        highlight_overrides = {
                            all.__raw = ''
                                function(cp)
                                    return {
                                        -- For base configs
                                        NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
                                        FloatBorder = {
                                            fg = transparent_background and cp.blue or cp.mantle,
                                            bg = transparent_background and cp.none or cp.mantle,
                                        },
                                        CursorLineNr = { fg = cp.green },

                                        -- For native lsp configs
                                        DiagnosticVirtualTextError = { bg = cp.none },
                                        DiagnosticVirtualTextWarn = { bg = cp.none },
                                        DiagnosticVirtualTextInfo = { bg = cp.none },
                                        DiagnosticVirtualTextHint = { bg = cp.none },
                                        LspInfoBorder = { link = "FloatBorder" },

                                        -- For mason.nvim
                                        MasonNormal = { link = "NormalFloat" },

                                        -- For indent-blankline
                                        IblIndent = { fg = cp.surface0 },
                                        IblScope = { fg = cp.surface2, style = { "bold" } },

                                        -- For nvim-cmp and wilder.nvim
                                        Pmenu = { fg = cp.overlay2, bg = transparent_background and cp.none or cp.base },
                                        PmenuBorder = { fg = cp.surface1, bg = transparent_background and cp.none or cp.base },
                                        PmenuSel = { bg = cp.green, fg = cp.base },
                                        CmpItemAbbr = { fg = cp.overlay2 },
                                        CmpItemAbbrMatch = { fg = cp.blue, style = { "bold" } },
                                        CmpDoc = { link = "NormalFloat" },
                                        CmpDocBorder = {
                                            fg = transparent_background and cp.surface1 or cp.mantle,
                                            bg = transparent_background and cp.none or cp.mantle,
                                        },

                                        -- For fidget
                                        FidgetTask = { bg = cp.none, fg = cp.surface2 },
                                        FidgetTitle = { fg = cp.blue, style = { "bold" } },

                                        -- For nvim-notify
                                        NotifyBackground = { bg = cp.base },

                                        -- For nvim-tree
                                        NvimTreeRootFolder = { fg = cp.pink },
                                        NvimTreeIndentMarker = { fg = cp.surface2 },

                                        -- For trouble.nvim
                                        TroubleNormal = { bg = transparent_background and cp.none or cp.base },
                                        TroubleNormalNC = { bg = transparent_background and cp.none or cp.base },

                                        -- For telescope.nvim
                                        TelescopeMatching = { fg = cp.lavender },
                                        TelescopeResultsDiffAdd = { fg = cp.green },
                                        TelescopeResultsDiffChange = { fg = cp.yellow },
                                        TelescopeResultsDiffDelete = { fg = cp.red },

                                        -- For glance.nvim
                                        GlanceWinBarFilename = { fg = cp.subtext1, style = { "bold" } },
                                        GlanceWinBarFilepath = { fg = cp.subtext0, style = { "italic" } },
                                        GlanceWinBarTitle = { fg = cp.teal, style = { "bold" } },
                                        GlanceListCount = { fg = cp.lavender },
                                        GlanceListFilepath = { link = "Comment" },
                                        GlanceListFilename = { fg = cp.blue },
                                        GlanceListMatch = { fg = cp.lavender, style = { "bold" } },
                                        GlanceFoldIcon = { fg = cp.green },

                                        -- For nvim-treehopper
                                        TSNodeKey = {
                                            fg = cp.peach,
                                            bg = transparent_background and cp.none or cp.base,
                                            style = { "bold", "underline" },
                                        },

                                        -- For treesitter
                                        ["@keyword.return"] = { fg = cp.pink, style = clear },
                                        ["@error.c"] = { fg = cp.none, style = clear },
                                        ["@error.cpp"] = { fg = cp.none, style = clear },
                                    }
                                end
                            '';
                        };
                    };
                };
            };
            plugins = {
                lz-n = {
                    enable = true;
                    autoLoad = true;
                };
                oil = {
                    enable = true;
                    settings = {
                        colums = [ "icon" ];
                        delete_to_trash = true;
                        cleanup_delay_ms = 10000;
                    };
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                which-key = {
                    enable = true;
                    settings = {
                        delay = 0;
                    };
                    lazyLoad = {
                        enable = true;
                        settings.keys = [ "<leader>" ];
                    };
                };
                gitsigns = {
                    enable = true;
                    settings = {
                        signs = {
                            add = {
                                text = "+";
                            };
                            change = {
                                text = "~";
                            };
                            delete = {
                                text = "_";
                            };
                            topdelete = {
                                text = "‾";
                            };
                            changedelete = {
                                text = "~";
                            };
                        };
                        on_attach = ''
                            function(bufnr)
                                local gitsigns = require 'gitsigns'


                                local function map(mode, l, r, opts)
                                    opts = opts or {}
                                    opts.buffer = bufnr
                                    vim.keymap.set(mode, l, r, opts)
                                end

                                -- Navigation
                                map('n', ']c', function()
                                    if vim.wo.diff then
                                        vim.cmd.normal { ']c', bang = true }
                                    else
                                        gitsigns.nav_hunk 'next'
                                    end
                                end, { desc = 'Jump to next git [c]hange' })

                                map('n', '[c', function()
                                    if vim.wo.diff then
                                        vim.cmd.normal { '[c', bang = true }
                                    else
                                        gitsigns.nav_hunk 'prev'
                                    end
                                end, { desc = 'Jump to previous git [c]hange' })

                                -- Actions
                                -- visual mode
                                -- map('v', 'wleaderwhs', function()
                                --   gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
                                -- end, { desc = 'git [s]tage hunk' })
                                map('v', '<leader>hr', function()
                                    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
                                end, { desc = 'git [r]eset hunk' })
                                -- normal mode
                                -- map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
                                map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
                                -- map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
                                -- map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
                                -- map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
                                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
                                map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
                                map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
                                map('n', '<leader>hD', function()
                                    gitsigns.diffthis '@'
                                end, { desc = 'git [D]iff against last commit' })
                                -- Toggles
                                -- map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
                                map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
                                map('n', '<leader>ha', gitsigns.blame, { desc = 'git blame line' })
                            end
                        '';
                    };
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                lazygit = {
                    enable = true;
                    settings = {
                        floating_window_border_chars = [
                            "╭"
                            "─"
                            "╮"
                            "│"
                            "╯"
                            "─"
                            "╰"
                            "│"
                        ];
                        floating_window_scaling_factor = 0.9;
                        floating_window_use_plenary = 0;
                        floating_window_winblend = 0;
                        use_custom_config_file_path = 0;
                        use_neovim_remote = 1;
                    };
                    # do not have in 25.11
                    # lazyLoad.enable = true;
                };
                nvim-autopairs = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings.event = "InsertEnter";
                    };
                };
                blink-cmp = {
                    enable = true;
                    setupLspCapabilities = true;
                    settings = {
                        appearance = {
                            nerd_font_variant = "mono";
                        };
                        completion = {
                            documentation = {
                                auto_show = false;
                                auto_show_delay_ms = 500;
                            };
                        };
                        sources = {
                            cmdline = [ ];
                            providers = {
                                buffer = {
                                    score_offset = -7;
                                };
                                lsp = {
                                    fallbacks = [ ];
                                };
                            };
                        };
                    };
                    lazyLoad = {
                        enable = true;
                        settings.event = [
                            "InsertEnter"
                            "CmdlineEnter"
                        ];
                    };
                };
                conform-nvim = {
                    enable = true;
                    settings = {
                        notify_on_error = true;
                        notify_no_formatters = true;
                        format_on_save = null;
                        formatters_by_ft = {
                            bash = [ "shfmt" ];
                            zsh = [ "shfmt" ];
                            sh = [ "shfmt" ];
                            c = [ "clang-format" ];
                            cpp = [ "clang-format" ];
                            cmake = [ "cmake-format" ];
                            html = [ "xmlstarlet" ];
                            xml = [ "xmlstarlet" ];
                            rust = [ "rustfmt" ];
                            lua = [ "stylua" ];
                            json = [ "jq" ];
                            nix = [ "nixfmt" ];
                        };
                        formatters = {
                            nixfmt = {
                                command = lib.getExe pkgs.nixfmt;
                                args = [
                                    "--indent=4"
                                    "--width=140" # because my Xiaomi Monitor can show 140 characters
                                ];
                            };
                        };
                    };
                    lazyLoad = {
                        enable = true;
                        settings = {
                            cmd = "ConformInfo";
                            event = "BufWritePre";
                            keys = [
                                {
                                    __unkeyed-1 = "<leader>cb";
                                    __unkeyed-2.__raw = ''
                                        function()
                                            require('conform').format { async = true, lsp_format = 'fallback' }
                                        end
                                    '';
                                    mode = "n";
                                    desc = "Conform Buffer";
                                }
                            ];
                        };
                    };
                };
                flash = {
                    enable = true;
                    settings = {
                        labels = "asdfghjklqwertyuiopzxcvbnm";
                        label = {
                            uppercase = false;
                            rainbow.enabled = false;
                        };
                        modes = {
                            search.enabled = false;
                            char.enabled = false;
                        };
                    };
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                fzf-lua = {
                    enable = true;
                    settings = {
                        winopts = {
                            fullscreen = true;
                            preview = {
                                vertical = "up:65%";
                                layout = "vertical";
                            };
                        };
                    };
                    lazyLoad = {
                        enable = false;
                        settings.event = [ "LspAttach" ];
                    };
                };
                indent-blankline = {
                    enable = true;
                    settings = {
                        exclude = {
                            buftypes = [
                                "terminal"
                                "quickfix"
                            ];
                            filetypes = [
                                ""
                                "checkhealth"
                                "help"
                                "lspinfo"
                                "packer"
                                "TelescopePrompt"
                                "TelescopeResults"
                                "yaml"
                            ];
                        };
                        indent = {
                            char = "│";
                        };
                        scope = {
                            show_end = false;
                            show_exact_scope = true;
                            show_start = false;
                        };
                    };
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                lualine = {
                    enable = true;
                    luaConfig.post = ''
                        local colors = {
                            red = '#ca1243',
                            black = '#000000',
                            white = '#f3f3f3',
                            light_green = '#83a598',
                            orange = '#fe8019',
                            green = '#8ec07c',
                        }

                        local theme = {
                            normal = {
                                a = { fg = colors.white, bg = colors.black },
                                b = { fg = colors.white, bg = colors.black },
                                c = { fg = colors.black, bg = colors.black },
                                z = { fg = colors.white, bg = colors.black },
                            },
                            insert = { a = { fg = colors.white, bg = colors.black } },
                            visual = { a = { fg = colors.white, bg = colors.black } },
                            replace = { a = { fg = colors.white, bg = colors.black } },
                        }

                        local function search_result()
                            if vim.v.hlsearch == 0 then
                                return ${"''"}
                            end
                            local last_search = vim.fn.getreg '/'
                            if not last_search or last_search == ${"''"} then
                                return ${"''"}
                            end
                            local searchcount = vim.fn.searchcount { maxcount = 9999 }
                            return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
                        end

                        local function fmt(str, left)
                            if str == nil or str == ${"''"} then
                                return str
                            end

                            if left then
                                return '|' .. str
                            else
                                return str .. '|'
                            end
                        end

                        local function modified()
                            if vim.bo.modified then
                                return '+'
                            elseif vim.bo.modifiable == false or vim.bo.readonly == true then
                                return '-'
                            end
                            return ${"''"}
                        end

                        require('lualine').setup {
                            options = {
                                theme = theme,
                                component_separators = ${"''"},
                                section_separators = ${"''"},
                                disabled_filetypes = { 'oil', 'alpha', 'dashboard', 'NvimTree', 'Outline' },
                            },
                            sections = {
                                lualine_a = {
                                    {
                                        'mode',
                                        fmt = function(str)
                                            return str:sub(1, 1)
                                        end,
                                        padding = 0,
                                    },
                                },
                                lualine_b = {
                                    {
                                        'branch',
                                        fmt = function(str)
                                            return fmt(str, true)
                                        end,
                                        padding = 0,
                                        icons_enabled = false,
                                        icon = nil,
                                        draw_empty = false,
                                    },
                                    {
                                        'diff',
                                        fmt = function(str)
                                            return fmt(str, true)
                                        end,
                                        padding = 0,
                                        draw_empty = false,
                                    },
                                    {
                                        'diagnostics',
                                        source = { 'nvim' },
                                        sections = { 'error' },
                                        diagnostics_color = { error = { bg = colors.red, fg = colors.black } },
                                        padding = 0,
                                    },
                                    {
                                        'diagnostics',
                                        source = { 'nvim' },
                                        sections = { 'warn' },
                                        diagnostics_color = { warn = { bg = colors.orange, fg = colors.black } },
                                        padding = 0,
                                        fmt = function(str)
                                            if str == nil or str == ${"''"} then
                                                return '|'
                                            end
                                            return str
                                        end,
                                    },
                                    {
                                        'filename',
                                        file_status = false,
                                        path = 0,
                                        padding = 0,
                                    },
                                    { modified, color = { bg = colors.red }, padding = 0 },
                                    {
                                        '%w',
                                        cond = function()
                                            return vim.wo.previewwindow
                                        end,
                                    },
                                    {
                                        '%r',
                                        cond = function()
                                            return vim.bo.readonly
                                        end,
                                    },
                                    {
                                        '%q',
                                        cond = function()
                                            return vim.bo.buftype == 'quickfix'
                                        end,
                                    },
                                },
                                lualine_c = {},
                                lualine_x = {},
                                lualine_y = {
                                    {
                                        search_result,
                                        padding = 0,
                                        fmt = function(str)
                                            return fmt(str, false)
                                        end,
                                    },
                                    -- {
                                    --   'filetype',
                                    --   padding = 0,
                                    --   icons_enabled = false,
                                    --   fmt = function(str)
                                    --     return fmt(str, false)
                                    --   end,
                                    -- },
                                },
                                lualine_z = {
                                    {
                                        '%l:%c',
                                        padding = 0,
                                        fmt = function(str)
                                            return fmt(str, false)
                                        end,
                                    },
                                    {
                                        '%p%%/%L',
                                        padding = 0,
                                    },
                                },
                            },
                            inactive_sections = {
                                lualine_c = { '%f %y %m' },
                                lualine_x = {},
                            },
                        }
                    '';
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                treesitter = {
                    enable = true;
                    highlight.enable = true;
                    indent.enable = true;
                    folding.enable = true;
                };
                todo-comments = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                toggleterm = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings = {
                            cmd = "ToggleTerm";
                        };
                    };
                };
                nvim-surround = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                fidget = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                rainbow-delimiters = {
                    enable = true;
                    lazyLoad = {
                        enable = true;
                        settings.event = "VimEnter";
                    };
                };
                neorg = {
                    enable = false;
                    # autoLoad = true;
                    settings = {
                        load = {
                            "core.concealer" = {
                                config = {
                                    icon_preset = "varied";
                                };
                            };
                            "core.defaults" = {
                                __empty = null;
                            };
                            "core.dirman" = {
                                config = {
                                    workspaces = {
                                        home = "~/workspaces/NeorgTest/home";
                                        work = "~/workspaces/NeorgTest/work";
                                    };
                                };
                            };
                        };
                    };
                    lazyLoad = {
                        enable = false;
                        settings = { };
                    };
                };
            };
            extraPlugins = [
                (pkgs.vimUtils.buildVimPlugin {
                    name = "log-highlight";
                    src = pkgs.fetchFromGitHub {
                        owner = "fei6409";
                        repo = "log-highlight.nvim";
                        rev = "v1.2.1";
                        hash = "sha256-jNmoWrF5xvRbD2ujezyeBmvU1Z7hLg981hVL5HA4pZk=";
                    };
                })
                pkgs.vimPlugins.outline-nvim
                pkgs.vimPlugins.quick-scope
            ];
            extraConfigLua = ''
                require("outline").setup({})
            '';
            extraConfigVim = ''
                let g:qs_highlight_on_keys = ['f', 'F']
                highlight QuickScopePrimary guifg='#ff0000' gui=bold,underline ctermfg=red cterm=bold,underline
                highlight QuickScopeSecondary guifg='#00ff00' gui=underline ctermfg=yellow cterm=underline
            '';
            lsp = {
                onAttach = ''
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    local function client_supports_method(client, method, bufnr)
                        return client:supports_method(method, bufnr)
                    end

                    require('fzf-lua').register_ui_select()
                    -- keymaps
                    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('gra', require('fzf-lua').lsp_code_actions, '[G]oto Code [A]ction', { 'n', 'x' })
                    map('grr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')
                    map('gri', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')
                    map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')
                    map('gD', require('fzf-lua').lsp_declarations, '[G]oto [D]eclaration')
                    map('<leader>q', require('fzf-lua').diagnostics_document, "questions")

                    map('<leader>d', vim.lsp.buf.hover, '[D]ocumentation')

                    -- lsp diagnostic UI
                    vim.diagnostic.config {
                        severity_sort = true,
                        float = { border = 'rounded', source = 'if_many' },
                        underline = { severity = vim.diagnostic.severity.ERROR },
                        signs = vim.g.have_nerd_font and {
                            text = {
                                [vim.diagnostic.severity.ERROR] = '󰅚 ',
                                [vim.diagnostic.severity.WARN] = '󰀪 ',
                                [vim.diagnostic.severity.INFO] = '󰋽 ',
                                [vim.diagnostic.severity.HINT] = '󰌶 ',
                            },
                        } or {},
                        virtual_text = {
                            source = 'if_many',
                            spacing = 2,
                            format = function(diagnostic)
                                local diagnostic_message = {
                                    [vim.diagnostic.severity.ERROR] = diagnostic.message,
                                    [vim.diagnostic.severity.WARN] = diagnostic.message,
                                    [vim.diagnostic.severity.INFO] = diagnostic.message,
                                    [vim.diagnostic.severity.HINT] = diagnostic.message,
                                }
                                return diagnostic_message[diagnostic.severity]
                            end,
                        },
                    }
                    local bufopts = { noremap = true, silent = true, buffer = bufnr }

                    map('<leader>D', vim.diagnostic.open_float, '[D]iagnos')

                    -- highlight under cursor
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- inlay hint
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                '';
                servers = {
                    lua_ls = {
                        enable = true;
                        config = {
                            root_markers = [
                                ".luarc.json"
                                ".luarc.jsonc"
                                ".luacheckrc"
                                ".stylua.toml"
                                "stylua.toml"
                                "selene.toml"
                                "selene.yml"
                                ".git"
                            ];
                            filetypes = [
                                "lua"
                            ];
                        };
                    };
                    clangd = {
                        enable = true;
                        config = {
                            cmd = [ "clangd" ];
                            filetypes = [
                                "c"
                                "cpp"
                                "objc"
                                "objcpp"
                                "cuda"
                                "proto"
                            ];
                            root_markers = [
                                ".clangd"
                                ".clang-tidy"
                                ".clang-format"
                                "compile_commands.json"
                                "compile_flags.txt"
                                "configure.ac"
                                ".git"
                            ];
                        };
                    };
                    nixd = {
                        enable = true;
                        config = {
                            cmd = [ "nixd" ];
                            filetypes = [ "nix" ];
                        };
                    };
                    rust_analyzer = {
                        enable = true;
                        config = {
                            cmd = [ "rust-analyzer" ];
                            filetypes = [ "rust" ];
                            root_dir.__raw = ''
                                function(bufnr, on_dir)
                                    local function is_library(fname)
                                        local user_home = vim.fs.normalize(vim.env.HOME)
                                        local cargo_home = os.getenv("CARGO_HOME") or user_home .. "/.cargo"
                                        local registry = cargo_home .. "/registry/src"
                                        local git_registry = cargo_home .. "/git/checkouts"

                                        local rustup_home = os.getenv("RUSTUP_HOME") or user_home .. "/.rustup"
                                        local toolchains = rustup_home .. "/toolchains"

                                        for _, item in ipairs({ toolchains, registry, git_registry }) do
                                            if vim.fs.relpath(item, fname) then
                                                local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
                                                return #clients > 0 and clients[#clients].config.root_dir or nil
                                            end
                                        end
                                    end
                                    local fname = vim.api.nvim_buf_get_name(bufnr)
                                    local reused_dir = is_library(fname)
                                    if reused_dir then
                                        on_dir(reused_dir)
                                        return
                                    end

                                    local cargo_crate_dir = vim.fs.root(fname, { "Cargo.toml" })
                                    local cargo_workspace_root

                                    if cargo_crate_dir == nil then
                                        on_dir(
                                            vim.fs.root(fname, { "rust-project.json" })
                                                or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
                                        )
                                        return
                                    end

                                    local cmd = {
                                        "cargo",
                                        "metadata",
                                        "--no-deps",
                                        "--format-version",
                                        "1",
                                        "--manifest-path",
                                        cargo_crate_dir .. "/Cargo.toml",
                                    }

                                    vim.system(cmd, { text = true }, function(output)
                                        if output.code == 0 then
                                            if output.stdout then
                                                local result = vim.json.decode(output.stdout)
                                                if result["workspace_root"] then
                                                    cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
                                                end
                                            end

                                            on_dir(cargo_workspace_root or cargo_crate_dir)
                                        else
                                            vim.schedule(function()
                                                vim.notify(
                                                    ("[rust_analyzer] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr)
                                                )
                                            end)
                                        end
                                    end)
                                end
                            '';
                            capabilities = {
                                experimental = {
                                    serverStatusNotification = true;
                                };
                            };
                            before_init.__raw = ''
                                function(init_params, config)
                                    -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
                                    if config.settings and config.settings['rust-analyzer'] then
                                        init_params.initializationOptions = config.settings['rust-analyzer']
                                    end
                                end
                            '';
                            on_attach.__raw = ''
                                function()
                                    vim.api.nvim_buf_create_user_command(0, 'LspCargoReload', function()
                                        local clients = vim.lsp.get_clients { bufnr = 0, name = 'rust_analyzer' }
                                        for _, client in ipairs(clients) do
                                            vim.notify 'Reloading Cargo Workspace'
                                            client.request('rust-analyzer/reloadWorkspace', nil, function(err)
                                                if err then
                                                    error(tostring(err))
                                                end
                                                vim.notify 'Cargo workspace reloaded'
                                            end, 0)
                                        end
                                    end, { desc = 'Reload current cargo workspace' })
                                end
                            '';
                        };
                    };
                    bashls = {
                        enable = true;
                        config = {
                            cmd = [
                                "bash-language-server"
                                "start"
                            ];
                            filetypes = [
                                "bash"
                                "sh"
                                "zsh"
                            ];
                            root_markers = [
                                ".git"
                            ];
                        };
                    };
                    gopls = {
                        enable = true;
                        config = {
                            cmd = [
                                "gopls"
                            ];
                            filetypes = [
                                "go"
                                "gomod"
                                "gowork"
                                "gotmpl"
                            ];
                            root_dir.__raw = ''
                                function(bufnr, on_dir)
                                    local mod_cache = nil
                                    local std_lib = nil
                                    ---@param custom_args go_dir_custom_args
                                    ---@param on_complete fun(dir: string | nil)
                                    local function identify_go_dir(custom_args, on_complete)
                                        local cmd = { 'go', 'env', custom_args.envvar_id }
                                        vim.system(cmd, { text = true }, function(output)
                                            local res = vim.trim(output.stdout or ${"''"})
                                            if output.code == 0 and res ~= ${"''"} then
                                                if custom_args.custom_subdir and custom_args.custom_subdir ~= ${"''"} then
                                                    res = res .. custom_args.custom_subdir
                                                end
                                                on_complete(res)
                                            else
                                                vim.schedule(function()
                                                    vim.notify(
                                                        ('[gopls] identify ' .. custom_args.envvar_id .. ' dir cmd failed with code %d: %s\n%s'):format(
                                                        output.code, vim.inspect(cmd), output.stderr)
                                                    )
                                                end)
                                                on_complete(nil)
                                            end
                                        end)
                                    end

                                    ---@return string?
                                    local function get_std_lib_dir()
                                        if std_lib and std_lib ~= ${"''"} then
                                            return std_lib
                                        end

                                        identify_go_dir({ envvar_id = 'GOROOT', custom_subdir = '/src' }, function(dir)
                                            if dir then
                                                std_lib = dir
                                            end
                                        end)
                                        return std_lib
                                    end

                                    ---@return string?
                                    local function get_mod_cache_dir()
                                        if mod_cache and mod_cache ~= ${"''"} then
                                            return mod_cache
                                        end

                                        identify_go_dir({ envvar_id = 'GOMODCACHE' }, function(dir)
                                            if dir then
                                                mod_cache = dir
                                            end
                                        end)
                                        return mod_cache
                                    end

                                    ---@param fname string
                                    ---@return string?
                                    local function get_root_dir(fname)
                                        if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
                                            local clients = vim.lsp.get_clients { name = 'gopls' }
                                            if #clients > 0 then
                                                return clients[#clients].config.root_dir
                                            end
                                        end
                                        if std_lib and fname:sub(1, #std_lib) == std_lib then
                                            local clients = vim.lsp.get_clients { name = 'gopls' }
                                            if #clients > 0 then
                                                return clients[#clients].config.root_dir
                                            end
                                        end
                                        return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
                                    end
                                    local fname = vim.api.nvim_buf_get_name(bufnr)
                                    get_mod_cache_dir()
                                    get_std_lib_dir()
                                    -- see: https://github.com/neovim/nvim-lspconfig/issues/804
                                    on_dir(get_root_dir(fname))
                                end
                            '';
                        };
                    };
                };
            };
        };
        wayprompt = {
            enable = true;
            settings = {
                general = {
                    font-regular = "sans:size=26";
                    pin-square-amount = 32;
                    border = 1;
                    pin-square-border = 2;
                    corner-radius = 0;
                };
                colours = {
                    background = "${theme_background}cc";
                    border = "${theme_bright_dark}ff";
                    text = "${theme_white}ff";
                    error-text = "${theme_bright_red}ff";

                    # =========================
                    # PIN 区域
                    # =========================

                    pin-background = "${theme_bright_background}cc";
                    pin-border = "${theme_bright_dark}ff";
                    pin-square = "${theme_bright_background}cc";

                    # =========================
                    # OK 按钮（主按钮）
                    # =========================

                    ok-button = "${theme_blue}cc";
                    ok-button-border = "${theme_bright_blue}ff";
                    ok-button-text = "${theme_bright_white}ff";

                    # =========================
                    # NOT OK（次级）
                    # =========================

                    not-ok-button = "${theme_bright_background}cc";
                    not-ok-button-border = "${theme_bright_dark}ff";
                    not-ok-button-text = "${theme_white}ff";

                    # =========================
                    # Cancel（低强调）
                    # =========================

                    cancel-button = "${theme_bright_background}cc";
                    cancel-button-border = "${theme_bright_dark}ff";
                    cancel-button-text = "${theme_bright_dark}ff";
                };
            };
        };
        gpg = {
            enable = true;
            homedir = "${config.home.homeDirectory}/.gnupg";
            mutableKeys = true;
            mutableTrust = true;
        };
    };
    services = {
        fnott = {
            enable = true;
            settings = {
                main = {
                    layer = "overlay";
                    title-color = "${theme_yellow}ff";
                    summary-color = "${theme_bright_dark}ff";
                    body-color = "${theme_white}ff";
                    background = "${theme_background}aa";
                    border-color = "${theme_tranparent}";
                    progress-color = "${theme_blue}ff";

                    max-width = 1000;
                    max-height = 500;
                    max-icon-size = 64;
                    anchor = "top-right";
                    stacking-order = "bottom-up";
                    selection-helper-uses-null-separator = "yes";
                    selection-helper = "\"fuzzel --dmenu0\"";
                    border-radius = 8;

                    dpi-aware = "yes";
                    title-font = "IBM Plex Sans:size=20";
                    summary-font = "IBM Plex Sans:size=19";
                    body-font = "IBM Plex Sans:size=18";

                    title-format = "<b>%a%A</b>";
                    summary-format = "<i>%s</i>";
                    body-format = "%b";

                    max-timeout = 0;
                    default-timeout = 10;
                    idle-timeout = 5;
                };
                critical = {
                    border-color = "${theme_red}ff";
                };
            };
        };
        ollama = {
            enable = true;
            package = pkgs.ollama-rocm;
            acceleration = "rocm";
            host = "127.0.0.1";
            port = 11434;
        };
        cliphist = {
            enable = true;
            extraOptions = [
                "-max-items"
                "1000"
            ];
        };
        pass-secret-service = {
            enable = true;
            storePath = "${config.home.homeDirectory}/.password-store";
        };
        swayidle =
            let
                lock = "${pkgs.swaylock}/bin/swaylock";
            in
            {
                enable = true;
                timeouts = [
                    {
                        timeout = 600;
                        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
                    }
                    {
                        timeout = 605;
                        command = lock;
                    }
                ];
                events = {
                    "before-sleep" = lock;
                };
            };
        gpg-agent = {
            enable = true;
            enableZshIntegration = true;
            pinentry = {
                package = pkgs.wayprompt;
                program = "pinentry-wayprompt";
            };
        };
    };
    fonts = {
        fontconfig = {
            enable = true;
            antialiasing = true; # setting this to true cause mako cannot display emoji
            subpixelRendering = "rgb";
            defaultFonts = {
                emoji = [ "Noto Color Emoji" ];
                # emoji = [ "OpenMoji Color" ];
                monospace = [
                    "IBM Plex Mono"
                    "Noto Sans Mono"
                    "Noto Sans Mono CJK SC"
                    "Noto Sans Mono CJK HK"
                    "Noto Sans Mono CJK TC"
                    "Noto Sans Mono CJK JP"
                    "Noto Sans Mono CJK KR"
                    "Symbols Nerd Font Mono"
                    # "Noto Color Emoji"
                ];
                sansSerif = [
                    "IBM Plex Sans"
                    "IBM Plex Sans SC"
                    "IBM Plex Sans TC"
                    "IBM Plex Sans JP"
                    "IBM Plex Sans KR"
                    "IBM Plex Sans Thai"
                    "IBM Plex Sans Thai Looped"
                    "IBM Plex Sans Hebrew"
                    "IBM Plex Sans Arabic"
                    "IBM Plex Sans Devanagari"
                    "Noto Sans"
                    "Noto Sans CJK SC"
                    "Noto Sans CJK HK"
                    "Noto Sans CJK TC"
                    "Noto Sans CJK JP"
                    "Noto Sans CJK KR"
                    # "Noto Color Emoji"
                ];
                serif = [
                    "IBM Plex Serif"
                    "Noto Serif"
                    "Noto Serif CJK SC"
                    "Noto Serif CJK HK"
                    "Noto Serif CJK TC"
                    "Noto Serif CJK JP"
                    "Noto Serif CJK KR"
                    # "Noto Color Emoji"
                ];
            };
        };
    };
    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
            waylandFrontend = true;
            ignoreUserConfig = false;
            addons = with pkgs; [
                (fcitx5-rime.override {
                    rimeDataPkgs = [
                        rime-ice
                    ];
                })
            ];
            # settings = {
            #   inputMethod = {
            #     GroupOrder."0" = "Default";
            #     "Groups/0" = {
            #       Name = "Default";
            #       "Default Layout" = "us";
            #       DefaultIM = "rime";
            #     };
            #     "Groups/0/Items/0".Name = "keyboard-us";
            #     "Groups/0/Items/1".Name = "rime";
            #   };
            #   globalOptions = {
            #     Behavior = {
            #       ActiveByDefault = false;
            #       resetStateWhenFocusIn = "No";
            #       ShareInputState = "No";
            #       PreeditEnabledByDefault = true;
            #       ShowInputMethodInformation= true;
            #       showInputMethodInformationWhenFocusIn = false;
            #       CompactInputMethodInformation = true;
            #       ShowFirstInputMethodInformation= true;
            #       DefaultPageSize = 9;
            #       OverrideXkbOption = false;
            #       PreloadInputMethod = true;
            #       AllowInputMethodForPassword = false;
            #       ShowPreeditForPassword = false;
            #       AutoSavePeriod = 30;
            #     };
            #     Hotkey = {
            #       EnumerateWithTriggerKeys = true;
            #       EnumerateSkipFirst = false;
            #       ModifierOnlyKeyTimeout = 250;
            #     };
            #     "Hotkey/TriggerKeys" = {
            #       "0" = "Control+space";
            #       "1" = "Zenkaku_Hankaku";
            #       "2" = "Hangul";
            #     };
            #     "Hotkey/AltTriggerKeys" = {
            #       "0" = "Shift_L";
            #     };
            #     "Hotkey/PrevPage" = {
            #       "0" = "Up";
            #     };
            #     "Hotkey/NextPage" = {
            #       "0" = "Down";
            #     };
            #     "Hotkey/PrevCandidate" = {
            #       "0" = "Shift+Tab";
            #     };
            #     "Hotkey/NextCandidate" = {
            #       "0" = "Tab";
            #     };
            #     "Hotkey/TogglePreedit" = {
            #       "0" = "Control+Alt+P";
            #     };
            #   };
            #   addons = {
            #     classicui.globalSection = {
            #       "Vertical Candidate List" = false;
            #       WheelForPaging = true;
            #       Font = "Noto Sans 18";
            #       MenuFont = "Noto Sans 10";
            #       TrayFont = "Noto Sans 10";
            #       TrayOutlineColor = "#000000";
            #       TrayTextColor = "#ffffff";
            #       PreferTextIcon = true;
            #       ShowLayoutNameInIcon = true;
            #       UseInputMethodLanguageToDisplayText = true;
            #       Theme= "catppuccin-mocha-rosewater";
            #       DarkTheme = "catppuccin-mocha-rosewater";
            #       UseDarkTheme = false;
            #       UseAccentColor = false;
            #       PerScreenDPI = false;
            #       ForceWaylandDPI = 0;
            #       EnableFractionalScale = true;
            #     };
            #     keyboard = {
            #       globalSection = {
            #         PageSize = 9;
            #         EnableEmoji = true;
            #         EnableQuickPhraseEmoji = true;
            #         "Choose Modifier" = "Alt";
            #         EnableHintByDefault = false;
            #         UseNewComposeBehavior = true;
            #         EnableLongPress = false;
            #         # PrevCandidate = {
            #         #   "0" = "Shift+Tab";
            #         # };
            #         # NextCandidate = {
            #         #   "0" = "Tab";
            #         # };
            #         # "Hint Trigger" = {
            #         #   "0" = "Control+Alt+H";
            #         # };
            #         # "One Time Hint Trigger" = {
            #         #   "0" = "Control + Alt + J";
            #         # };
            #       };
            #     };
            #   };
            # };
        };
    };
}
