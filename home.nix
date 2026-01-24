{
    lib,
    config,
    pkgs,
    inputs,
    ...
}:

let
    installedJDKs = with pkgs; [
        jdk21
        jdk17
        jdk11
        jdk8
    ];
    defaultJDK = builtins.elemAt installedJDKs 0;
    projDir = "${config.xdg.userDirs.extraConfig.XDG_WORKSPACE_DIR}/spreadconfig";
    secretsDir = "${projDir}/secrets";
    scriptsDir = "${config.home.homeDirectory}/scripts";
    spreadconfigDir = "${config.home.homeDirectory}/workspaces/spreadconfig/spreadconfig";
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
            # QT_SCREEN_SCALE_FACTORS= "eDP-1=2.0;HDMI-A-1=1.0;DP-2=1.0";
            # LESS = "-R --use-color -Dd+r$Du+b$";
            # MANPAGER = "sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'";
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
        ];
        file = {
            # ".config/vivaldi_custom".source = ./spreadconfig/config/vivaldi_custom;
            # ".config/qutebrowser/autoconfig.yml".source = ./spreadconfig/config/qutebrowser/autoconfig.yml;
            "${scriptsDir}" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/scripts";
            };
            "${config.xdg.configHome}/niri" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/niri";
            };
            "${config.xdg.configHome}/mako" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/mako";
            };
            "${config.xdg.configHome}/foot" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/foot";
            };
            "${config.xdg.configHome}/waybar" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/waybar";
            };
            "${config.xdg.configHome}/wofi" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/wofi";
            };
            "${config.xdg.configHome}/starship/starship.toml" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/starship.toml";
            };
            "${config.xdg.configHome}/swaylock" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/swaylock";
            };
            "${config.xdg.dataHome}/fcitx5/rime/rime-data" = {
                source = "${pkgs.rime-ice}/share/rime-data";
            };
            "${config.xdg.dataHome}/fcitx5/rime/default.custom.yaml" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/input/default";
            };
            "${config.xdg.configHome}/obs-studio/basic/profiles/Video" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Video";
            };
            "${config.xdg.configHome}/obs-studio/basic/profiles/Audio" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/obs/profiles/Audio";
            };
            "${config.xdg.configHome}/qutebrowser/quickmarks" = {
                source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/qutebrowser_quickmarks";
            };
            "${config.xdg.configHome}/qutebrowser/config.py" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/qutebrowser/config.py";
            };
            "${config.home.homeDirectory}/.ideavimrc" = {
                source = config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/Jetbrains/.ideavimrc";
            };
        }
        # jdk
        // (builtins.listToAttrs (
            map (jdk: {
                name = "${config.home.homeDirectory}/Lib/jdks/${jdk.version}";
                value = {
                    source = jdk;
                };
            }) installedJDKs
        ));
        # activation.mergeQutebrowserQuickmarks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        #   set -euo pipefail
        #   DST="${config.xdg.configHome}/qutebrowser/quickmarks"
        #   SRC=${qutebrowser-quickmarks}
        #   mkdir -p "$(dirname "$DST")"
        #   if [ ! -f "$DST" ]; then
        #     cp "$SRC" "$DST"
        #   else
        #     backup="${config.home.homeDirectory}/temp/backup/qutebrowser-quickmarks-backup-$(date +%s)"
        #     mkdir -p "$(dirname "$backup")"
        #     cp "$DST" "$backup"
        #     tmp="$(mktemp)"
        #     trap 'rm -f "$tmp"' EXIT
        #     cat "$DST" "$SRC" | sort -u > "$tmp"
        #     mv "$tmp" "$DST"
        #   fi
        #   chmod +w "$DST"
        # '';
        pointerCursor = {
            enable = true;
            package = pkgs.adwaita-icon-theme;
            gtk.enable = true;
            name = "Adwaita";
            size = 72;
            x11.enable = true;
        };
        packages = with pkgs; [
            zsh-syntax-highlighting
            zsh-autosuggestions
            zsh-completions
            zsh-fzf-tab
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
            rustfmt
            rust-analyzer
            python3
            nixd
            nixfmt
            lua-language-server
            stylua
            bash-language-server
            fastfetch
            onefetch
            btop
            tealdeer
            nix-tree
            # rustup
            gdu
            bluetui
            eza
            bat
            duf
            dust
            diff-so-fancy
            rar
            unzip
            zip
            (wechat.overrideAttrs (old: {
                postFixup = (old.postFixup or "") + ''
                    substituteInPlace $out/share/applications/wechat.desktop \
                      --replace-fail \
                      "Exec=wechat" \
                      "Exec=env QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx QT_SCREEN_SCALE_FACTORS='eDP-1=2.0;HDMI-A-1=1.0;DP-2=1.0' wechat"
                '';
            }))
            (qq.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/qq.desktop \
                      --replace-fail "$out/bin/qq" "$out/bin/qq --ozone-platform-hint=auto --enable-wayland-ime --wayland-text-input-version=3"
                '';
            }))
            qutebrowser
            # vivaldi
            # (pkgs.qutebrowser.overrideAttrs (old: {
            #   postInstall = (old.postInstall or "") + ''
            #     set -euo pipefail
            #     DST="${config.xdg.configHome}/qutebrowser/quickmarks"
            #     SRC=${qutebrowser-quickmarks}
            #     mkdir -p "$(dirname "$DST")"
            #     if [ ! -f "$DST" ]; then
            #       cp "$SRC" "$DST"
            #     else
            #       tmp="$(mktemp)"
            #       trap 'rm -f "$tmp"' EXIT
            #       cat "$DST" "$SRC" \
            #         | sort -u > "$tmp"
            #       mv "$tmp" "$DST"
            #     fi
            #   '';
            # }))
            nautilus
            seahorse
            obsidian
            file-roller
            # (pkgs.writeShellScriptBin "scrcpy" ''
            #   exec ${pkgs.scrcpy}/bin/scrcpy --render-driver=opengl "$@"
            # '')
            (pkgs.scrcpy.overrideAttrs (old: {
                postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/share/applications/scrcpy.desktop \
                      --replace-fail "-c scrcpy\"" \
                                     "-c 'scrcpy --render-driver=opengl'\""
                    rm $out/share/applications/scrcpy-console.desktop
                '';
            }))
            jetbrains-toolbox
            niri
            xwayland-satellite
            foot
            mako
            waybar
            xeyes
            wayfreeze
            grim
            slurp
            wf-recorder
            libnotify
            wl-clipboard
            qrencode
            pastel
            telegram-desktop
            jadx
            ghidra-bin
            pass
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
            nerd-fonts.symbols-only
            gcr # https://wiki.nixos.org/wiki/Secret_Service#GNOME_Keyring
        ];
    };
    systemd.user.services = {
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
                    "mako.service"
                    "waybar.service"
                    "foot-server.service"
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
    };
    xdg = {
        enable = true;
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
                exec = "shutdown -h now";
                icon = "";
                terminal = false;
            };
            reboot = {
                name = "Reboot";
                type = "Application";
                exec = "reboot";
                icon = "";
                terminal = false;
            };
            wechat = {
                name = "wechat";
                exec = ''env QT_IM_MODULE="fcitx" XMODIFIERS="@im=fcitx" QT_SCREEN_SCALE_FACTORS="eDP-1=2.0;HDMI-A-1=1.0;DP-2=1.0" wechat %U'';
                terminal = false;
                icon = "wechat";
                type = "Application";
                categories = [
                    "Utility"
                ];
            };
            nvim = {
                name = "Neovim";
                exec = "footclient --title=nvim -- nvim %F";
                terminal = false;
                type = "Application";
                icon = "nvim";
                categories = [
                    "TextEditor"
                    "Utility"
                ];
                mimeType = [
                    "text/english"
                    "text/plain"
                    "text/x-makefile"
                    "text/x-c++hdr"
                    "text/x-c++src"
                    "text/x-chdr"
                    "text/x-csrc"
                    "text/x-java"
                    "text/x-moc"
                    "text/x-pascal"
                    "text/x-tcl"
                    "text/x-tex"
                    "application/x-shellscript"
                    "text/x-c"
                    "text/x-c++"
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
        };
        portal = {
            enable = true;
            configPackages = with pkgs; [
                xdg-desktop-portal-gnome
            ];
            extraPortals = with pkgs; [
                xdg-desktop-portal-gnome
            ];
        };
        userDirs = {
            enable = true;
            createDirectories = true;
            extraConfig = {
                XDG_LIB_DIR = "${config.home.homeDirectory}/Lib";
                XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/workspaces";
                XDG_TEMP_DIR = "${config.home.homeDirectory}/temp";
                XDG_SATTY_DIR = "${config.xdg.userDirs.pictures}/satty";
                XDG_SCREENSHOT_DIR = "${config.xdg.userDirs.pictures}/screenshot";
                XDG_SCREENRECORD_DIR = "${config.xdg.userDirs.videos}/screenrecord";
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
        cursorTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
            size = 72;
        };
        theme = {
            name = "Adwaita";
            package = pkgs.gnome-themes-extra;
        };
        font = {
            name = "Noto Sans";
            size = 16;
        };
        iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
        };
        gtk3 = {
            enable = true;
            bookmarks = [
                "file://${config.xdg.userDirs.documents}"
                "file://${config.xdg.userDirs.download}"
                "file://${config.xdg.userDirs.music}"
                "file://${config.xdg.userDirs.pictures}"
                "file://${config.xdg.userDirs.videos}"
                "file://${config.xdg.userDirs.extraConfig.XDG_WORKSPACE_DIR} WORK"
                "file://${config.xdg.userDirs.extraConfig.XDG_LIB_DIR}"
                "file://${config.xdg.userDirs.extraConfig.XDG_TEMP_DIR}"
                "file://${config.xdg.userDirs.extraConfig.XDG_SCREENSHOT_DIR}"
                "file://${config.xdg.userDirs.extraConfig.XDG_SCREENRECORD_DIR}"
                "davs://spreadzhao.cloud:10116/ NAS"
            ];
            colorScheme = "dark";
            cursorTheme = {
                name = "Adwaita";
                package = pkgs.adwaita-icon-theme;
                size = 72;
            };
            font = {
                name = "Noto Sans";
                size = 16;
            };
            iconTheme = {
                name = "Adwaita";
                package = pkgs.adwaita-icon-theme;
            };
            theme = {
                name = "Adwaita";
                package = pkgs.gnome-themes-extra;
            };
        };
        gtk4 = {
            enable = true;
            colorScheme = "dark";
            cursorTheme = {
                name = "Adwaita";
                package = pkgs.adwaita-icon-theme;
                size = 72;
            };
            font = {
                name = "Noto Sans";
                size = 16;
            };
            iconTheme = {
                name = "Adwaita";
                package = pkgs.adwaita-icon-theme;
            };
            theme = {
                name = "Adwaita";
                package = pkgs.gnome-themes-extra;
            };
        };
    };
    qt = {
        enable = true;
        platformTheme.name = "xdgdesktopportal";
        style = {
            package = pkgs.adwaita-qt;
            name = "adwaita-dark";
        };
    };
    programs = {
        swaylock.enable = true;
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
        lazygit = {
            enable = true;
            enableZshIntegration = true;
            settings = {
                gui = {
                    nerdFontsVersion = "3";
                };
                git = {
                    pagers = [
                        {
                            pager = "diff-so-fancy";
                        }
                    ];
                    autoFetch = false;
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
        wofi = {
            enable = true;
        };
        feh = {
            enable = true;
            themes = {
                booth = [
                    "--full-screen"
                    "--hide-pointer"
                    "--slideshow-delay"
                    "20"
                ];
                example = [
                    "--info"
                    "foo bar"
                ];
                feh = [
                    "--image-bg"
                    "black"
                ];
                imagemap = [
                    "-rVq"
                    "--thumb-width"
                    "40"
                    "--thumb-height"
                    "30"
                    "--index-info"
                    "%n\\n%wx%h"
                ];
                present = [
                    "--full-screen"
                    "--sort"
                    "name"
                    "--hide-pointer"
                ];
                webcam = [
                    "--multiwindow"
                    "--reload"
                    "20"
                ];
                fit = [
                    "--scale-down"
                    "--auto-zoom"
                ];
            };
        };
        satty = {
            enable = true;
            settings = {
                general = {
                    fullscreen = false;
                    early-exit = true;
                    corner-roundness = 0;
                    initial-tool = "brush";
                    copy-command = "wl-copy";
                    annotation-size-factor = 1;
                    output-filename = "~/Pictures/satty/satty-%Y%m%d-%H%M%S.png";
                    save-after-copy = false;
                    default-hide-toolbars = false;
                    focus-toggles-toolbars = false;
                    default-fill-shapes = false;
                    primary-highlighter = "block";
                    disable-notifications = false;
                    actions-on-right-click = [ ];
                    actions-on-enter = [ ];
                    actions-on-escape = [ "exit" ];
                    right-click-copy = false;
                    no-window-decoration = true;
                };
            };
        };
        mpv = {
            enable = true;
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
                # lg = "lazygit";
                c = "clear";
                wk = "cd ~/workspaces";
                sb = "cd ~/workspaces/SecondBrain/";
                st = "cd ~/workspaces/SpreadStudy/";
                lc = "cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n";
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
                # grep = "grep --color=auto";
                # fzf = ''fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'';
            };
            shellGlobalAliases = {
                # "--help" = "--help 2>&1 | bat --language=help --style=plain";
            };
            initContent = lib.mkOrder 2000 ''
                source ${scriptsDir}/config/config_zsh_nix.sh
                source ${scriptsDir}/config/color_output.sh
            '';
        };
        starship = {
            enable = true;
            configPath = "${config.xdg.configHome}/starship/starship.toml";
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
                    callback = {
                        __raw = ''
                            function()
                              vim.hl.on_yank()
                            end
                        '';
                    };
                }
            ];
            keymaps = [
                {
                    key = "<Esc>";
                    action = "<CMD>nohlsearch<CR>";
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
                    key = "<leader>cb";
                    action = {
                        __raw = ''
                            function()
                                require('conform').format { async = true, lsp_format = 'fallback' }
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Conform Buffer";
                    };
                }
                {
                    key = "<leader>;";
                    action = {
                        __raw = ''
                            function()
                                require('flash').jump()
                            end
                        '';
                    };
                    mode = "n";
                    options = {
                        desc = "Jump Code";
                    };
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
            colorschemes.vscode = {
                enable = true;
                settings = {
                    transparent = true;
                    italic_comments = true;
                    underline_links = true;
                    disable_nvimtree_bg = true;
                    terminal_colors = false;
                    color_overrides = {
                        vscLineNumber = "#FFFFFF";
                    };
                };
            };
            plugins = {
                oil = {
                    enable = true;
                    settings = {
                        colums = [ "icon" ];
                        delete_to_trash = true;
                        cleanup_delay_ms = 10000;
                    };
                };
                which-key = {
                    enable = true;
                    settings = {
                        delay = 0;
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
                                -- map('v', '<leader>hs', function()
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
                };
                nvim-autopairs = {
                    enable = true;
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
                                ];
                            };
                        };
                    };
                };
                flash = {
                    enable = true;
                    settings = {
                        modes.char.enabled = false;
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
                };
                treesitter = {
                    enable = true;
                    # highlight.enable = true;
                    # indent.enable = true;
                    folding = true;
                    settings = {
                        auto_install = true;
                        # ensure_installed = "all";
                        highlight.enable = true;
                        indent.enable = true;
                    };
                };
                todo-comments = {
                    enable = true;
                };
                toggleterm = {
                    enable = true;
                };
                nvim-surround = {
                    enable = true;
                };
                fidget = {
                    enable = true;
                    # settings = {
                    #   notification = {
                    #     window = {
                    #       winblend = 0;
                    #     };
                    #   };
                    #   progress = {
                    #     display = {
                    #       done_icon = "";
                    #       done_ttl = 7;
                    #       format_message = lib.nixvim.mkRaw ''
                    #         function(msg)
                    #           if string.find(msg.title, "Indexing") then
                    #             return nil -- Ignore "Indexing..." progress messages
                    #           end
                    #           if msg.message then
                    #             return msg.message
                    #           else
                    #             return msg.done and "Completed" or "In progress..."
                    #           end
                    #         end
                    #       '';
                    #     };
                    #   };
                    #   text = {
                    #     spinner = "dots";
                    #   };
                    # };
                };
                rainbow-delimiters = {
                    enable = true;
                };
                # rainbow = {
                #   enable = true;
                #   settings = {
                #     active = 1;
                #     # conf = {
                #     #   guifgs = [
                #     #     "#7d8618"
                #     #     "darkorange3"
                #     #     "seagreen3"
                #     #     "firebrick"
                #     #   ];
                #     #   operators = "_,_";
                #     #   parentheses = [
                #     #     "start=/(/ end=/)/ fold"
                #     #     "start=/\\[/ end=/\\]/ fold"
                #     #   ];
                #     #   separately = {
                #     #     "*" = { };
                #     #     css = 0;
                #     #     haskell = {
                #     #       parentheses = [
                #     #         "start=/\\[/ end=/\\]/ fold"
                #     #         "start=/v{ze[^-]/ end=/}/ fold"
                #     #       ];
                #     #     };
                #     #     markdown = {
                #     #       parentheses_options = "containedin=markdownCode contained";
                #     #     };
                #     #   };
                #     # };
                #   };
                # };
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
                # (pkgs.vimUtils.buildVimPlugin {
                #     name = "outline";
                #     src = pkgs.fetchFromGitHub {
                #       owner = "hedyhli";
                #       repo = "outline.nvim";
                #       rev = "v1.1.0";
                #       hash = "sha256-fbNVSAOzdmmfTV4CkssTpw54IZbCCLUOguO/huEB6eU=";
                #     };
                #     doCheck = false;
                # })
            ];
            extraConfigLua = ''
                require("outline").setup({})
            '';
            extraConfigVim = ''
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
                            root_dir = {
                                __raw = ''
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
                            };
                            capabilities = {
                                experimental = {
                                    serverStatusNotification = true;
                                };
                            };
                            before_init = {
                                __raw = ''
                                    function(init_params, config)
                                        -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
                                        if config.settings and config.settings['rust-analyzer'] then
                                            init_params.initializationOptions = config.settings['rust-analyzer']
                                        end
                                    end
                                '';
                            };
                            on_attach = {
                                __raw = ''
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
                };
            };
        };
        zathura = {
            enable = true;
            options = {
                adjust-open = "best-fit";
                pages-per-row = 1;
                scroll-page-aware = "true";
                font = "Noto Sans 20";
            };
        };
        gpg = {
            enable = true;
            homedir = "${config.xdg.dataHome}/gnupg";
            mutableKeys = true;
            mutableTrust = true;
        };
    };
    services = {
        cliphist = {
            enable = true;
            extraOptions = [
                "-max-items"
                "1000"
            ];
        };
        gnome-keyring.enable = true;
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
                # events = {
                #   "before-sleep" = lock;
                # };
                events = [
                    {
                        event = "before-sleep";
                        command = lock;
                    }
                ];
            };
        gpg-agent = {
            enable = true;
            enableZshIntegration = true;
            pinentry = {
                package = pkgs.pinentry-gnome3;
                program = "pinentry-gnome3";
            };
        };
    };
    fonts = {
        fontconfig = {
            enable = true;
            antialiasing = true;
            defaultFonts = {
                emoji = [ "Noto Color Emoji" ];
                monospace = [
                    "Noto Sans Mono"
                    "Noto Sans Mono CJK SC"
                    "Noto Sans Mono CJK HK"
                    "Noto Sans Mono CJK TC"
                    "Noto Sans Mono CJK JP"
                    "Noto Sans Mono CJK KR"
                    "Symbols Nerd Font Mono"
                    "Noto Color Emoji"
                ];
                sansSerif = [
                    "Noto Sans"
                    "Noto Sans CJK SC"
                    "Noto Sans CJK HK"
                    "Noto Sans CJK TC"
                    "Noto Sans CJK JP"
                    "Noto Sans CJK KR"
                    "Noto Color Emoji"
                ];
                serif = [
                    "Noto Serif"
                    "Noto Serif CJK SC"
                    "Noto Serif CJK HK"
                    "Noto Serif CJK TC"
                    "Noto Serif CJK JP"
                    "Noto Serif CJK KR"
                    "Noto Color Emoji"
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
            #       Theme= "default-dark";
            #       DarkTheme = "default-dark";
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
