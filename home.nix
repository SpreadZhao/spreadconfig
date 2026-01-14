{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];
  home = {
    username = "spreadzhao";
    homeDirectory = "/home/spreadzhao";
    stateVersion = "25.11";
    file = {
      "${config.home.homeDirectory}/scripts".source = ./spreadconfig/scripts;
      "${config.xdg.configHome}/niri".source = ./spreadconfig/config/niri;
      "${config.xdg.configHome}/mako".source = ./spreadconfig/config/mako;
      "${config.xdg.configHome}/foot".source = ./spreadconfig/config/foot;
      "${config.xdg.configHome}/waybar".source = ./spreadconfig/config/waybar;
      "${config.xdg.configHome}/wofi".source = ./spreadconfig/config/wofi;
      # ".config/vivaldi_custom".source = ./spreadconfig/config/vivaldi_custom;
      "${config.xdg.configHome}/starship.toml".source = ./spreadconfig/config/starship.toml;
      "${config.xdg.configHome}/swaylock".source = ./spreadconfig/config/swaylock;
      "${config.xdg.dataHome}/fcitx5/rime/default.custom.yaml".source = ./spreadconfig/input/default;
      "${config.xdg.configHome}/obs-studio/basic/profiles/Video".source = ./spreadconfig/config/obs/profiles/Video;
      "${config.xdg.configHome}/obs-studio/basic/profiles/Audio".source = ./spreadconfig/config/obs/profiles/Audio;
      "${config.xdg.configHome}/qutebrowser/quickmarks".source = ./spreadconfig/config/qutebrowser/quickmarks;
      # ".config/qutebrowser/autoconfig.yml".source = ./spreadconfig/config/qutebrowser/autoconfig.yml;
      "${config.xdg.configHome}/qutebrowser/config.py".source = ./spreadconfig/config/qutebrowser/config.py;
      "${config.home.homeDirectory}/.ideavimrc".source = ./spreadconfig/Jetbrains/.ideavimrc;
    };
    pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      gtk.enable = true;
      name = "Adwaita";
      size = 72;
      x11.enable = true;
    };
    packages = with pkgs; [
      wechat
      qq
      # vivaldi
      qutebrowser
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
      mako
      waybar
      swaylock
      swayidle
      xwayland-satellite
      xeyes
      wayfreeze
      grim
      slurp
      wf-recorder
      libnotify
      wl-clipboard
    ];
  };
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
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
  xdg = {
    enable = true;
    desktopEntries = {
      toggle_monitor = {
        name = "Toggle Monitor";
        comment = "Toggle Monitor on and off";
        exec = "${config.home.homeDirectory}/scripts/niri/niri_toggle_output.sh";
        type = "Application";
      };
      foot_new_tab = {
        name = "Foot New Tab";
        type = "Application";
        exec = "${config.home.homeDirectory}/scripts/niri/foot_new_tab.sh";
        terminal = false;
      };
      change_audio = {
        name = "Change Audio Device";
        type = "Application";
        exec = "/usr/bin/env python3 ${config.home.homeDirectory}/scripts/util/change_audio.py";
        categories = [
          "AudioVideo"
          "Utility"
        ];
      };
      shutdown = {
        name = "Shutdown";
        type = "Application";
        exec = "shutdown -h now";
        terminal = false;
      };
      reboot = {
        name = "Reboot";
        type = "Application";
        exec = "reboot";
        terminal = false;
      };
      wechat = {
        name = "wechat";
        exec = ''env QT_IM_MODULE="fcitx" XMODIFIERS="@im=fcitx" QT_SCREEN_SCALE_FACTORS="eDP-1=2.0;HDMI-A-1=1.0;DP-2=1.0" wechat %U'';
        terminal = false;
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
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
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
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "SpreadZhao";
          email = "spreadzhao@outlook.com";
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
          oauth_token = "xxx";
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
          actions-on-right-click = [];
          actions-on-enter = [];
          actions-on-escape = [ "exit" ];
          right-click-copy = false;
          no-window-decoration = true;
        };
      };
    };
    mpv = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = false;
      dotDir = "${config.xdg.configHome}/zsh";
      initContent = lib.mkOrder 2000 ''
        source ~/scripts/config/config.zsh
      '';
    };
    starship = {
      enable = true;
    };
    nixvim = {
      enable = true;
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
        shiftwidth = 2;
        tabstop = 2;
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
          "highlight-yank" = { clear = true; };
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
            colums = ["icon"];
            delete_to_trash = true;
            cleanup_delay_ms = 100;
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
                      add = { text = "+"; };
                      change = { text = "~"; };
                      delete = { text = "_"; };
                      topdelete = { text = "‾"; };
                      changedelete = { text = "~"; };
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
          settings = 
              {
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
          highlight.enable = true;
          indent.enable = true;
          folding.enable = true;
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
        # (pkgs.vimUtils.buildVimPlugin {
        #     name = "outline";
        #     src = pkgs.fetchFromGitHub {
        #       owner = "hedyhli";
        #       repo = "outline.nvim";
        #       rev = "v1.1.0";
        #       hash = "sha256-fbNVSAOzdmmfTV4CkssTpw54IZbCCLUOguO/huEB6eU=";
        #     };
        # })
      ];
      lsp = {
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

      };
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
    gnome-keyring = {
      enable = true;
    };
  };
}
