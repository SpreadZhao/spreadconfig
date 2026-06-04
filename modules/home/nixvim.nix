{
  pkgs,
  mochaBg,
  ...
}:

let
  normalMode = "n";
  visualMode = "v";
  normalVisualModes = [
    normalMode
    visualMode
  ];

  leaderKey = "<leader>";
  leader = suffix: "${leaderKey}${suffix}";
  cmd = command: "<CMD>${command}<CR>";
  cmds = commands: builtins.concatStringsSep "" (map cmd commands);
  normalDesc = desc: { inherit desc; };
  noremapDesc = desc: {
    inherit desc;
    noremap = true;
  };
  normalKey = key: action: desc: {
    inherit key action;
    mode = normalMode;
    options = normalDesc desc;
  };
  normalNoremapKey = key: action: desc: {
    inherit key action;
    mode = normalMode;
    options = noremapDesc desc;
  };
  fzfLuaAction = call: {
    __raw = ''
      function()
          require('fzf-lua').${call}
      end
    '';
  };

  vimEnter = "VimEnter";
  insertEnter = "InsertEnter";
  cmdlineEnter = "CmdlineEnter";
  lspAttach = "LspAttach";
  bufWritePre = "BufWritePre";
  lazyLoadOn = event: {
    enable = true;
    settings.event = event;
  };
  vimEnterLazyLoad = lazyLoadOn vimEnter;
  insertEnterLazyLoad = lazyLoadOn insertEnter;

  bold = "bold";
  italic = "italic";
  underline = "underline";
  boldStyle = [ bold ];
  italicStyle = [ italic ];
  underlineStyle = [ underline ];

  vscodeColors = {
    lineNumber = "#a6adc8";
    back = "#000000";
    lineNumberDark = "#7C7C7C";
    cursorDarkDark = "#262626";
    selection = "#262626";
    foreground = "#ADAEAC";
    comment = "#6A9955";
    keyword = "#47A2ED";
    static = "#FFC66D";
    type = "#47CCB1";
    function = "#E6E6AA";
    error = "#F44747";
    string = "#CD9069";
  };

  singleCommand = command: [ command ];
  singleFiletype = filetype: [ filetype ];
  shfmtFormatter = singleCommand "shfmt";
  clangFormatFormatter = singleCommand "clang-format";
  xmlstarletFormatter = singleCommand "xmlstarlet";
  gitRootMarker = ".git";
in
{
  programs.nixvim = {
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
      smartindent = true;
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
      # autocomplete = true;
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
      LineNrAbove.fg = vscodeColors.lineNumber;
      LineNrBelow.fg = vscodeColors.lineNumber;
    };
    keymaps = [
      {
        key = "'";
        action = "$";
        mode = normalVisualModes;
      }
      {
        key = "<Esc>";
        action = cmd "nohlsearch";
        mode = normalMode;
      }
      {
        key = "<C-h>";
        action = "<C-w><C-h>";
        mode = normalMode;
      }
      {
        key = "<C-l>";
        action = "<C-w><C-l>";
        mode = normalMode;
      }
      {
        key = "<C-j>";
        action = "<C-w><C-j>";
        mode = normalMode;
      }
      {
        key = "<C-k>";
        action = "<C-w><C-k>";
        mode = normalMode;
      }
      {
        key = "gk";

        action = "<C-o>";
        mode = normalMode;
        options = noremapDesc "go back";
      }
      {
        key = "gj";
        action = "<C-i>";
        mode = normalMode;
        options = noremapDesc "go forward";
      }
      {
        key = "/";
        mode = visualMode;
        action = ''""y/\V<C-R>=escape(@", '/\')<CR><CR>'';
        options = normalDesc "Search Visual Selection";
      }
      (normalKey (leader "fs") (cmd "Oil") "File System")
      (normalKey (leader "nt") (cmds [
        "tabnew"
        "Oil"
      ]) "New Tab")
      (normalKey (leader "lg") (cmd "LazyGit") "LazyGit")
      {
        key = leader ";";
        action.__raw = ''
          function()
              require('flash').jump()
          end
        '';
        mode = normalMode;
        options = normalDesc "Jump Code";
      }
      (normalKey (leader "ff") (fzfLuaAction "files()") "Find Files")
      (normalKey (leader "ge") (fzfLuaAction "buffers()") "Find Buffers")
      (normalKey (leader "fh") (fzfLuaAction "oldfiles()") "Find History")
      (normalKey (leader "ft") (fzfLuaAction "tabs()") "Find Tab")
      (normalKey (leader "fk") (fzfLuaAction "keymaps()") "Find Keymaps")
      (normalKey (leader "fe") (fzfLuaAction "live_grep({ resume = true })") "Find Everything")
      (normalKey (leader "?") (fzfLuaAction "helptags()") "Find Helps")
      {
        key = leader "fe";
        action = fzfLuaAction "grep_visual()";
        mode = visualMode;
        options = normalDesc "Find Under Cursor";
      }
      (normalNoremapKey (leader "tt") (cmd "ToggleTerm") "Toggle Term")
      (normalNoremapKey (leader "ot") (cmd "Outline") "Toggle Outline")
      (normalNoremapKey (leader "of") (cmd "OutlineFocus") "Focus Outline")
      {
        key = leader "u";
        action.__raw = ''
          function()
            vim.cmd.packadd("nvim.undotree")
            require("undotree").open()
          end
        '';
        mode = normalMode;
        options = noremapDesc "Toggle Builtin Undotree";
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
            vscBack = vscodeColors.back;
            vscLineNumber = vscodeColors.lineNumberDark;
            vscCursorDarkDark = vscodeColors.cursorDarkDark;
            vscSelection = vscodeColors.selection;
            vscForeground = vscodeColors.foreground;
          };

          group_overrides = {
            # ===== 注释 =====
            Comment = {
              fg = vscodeColors.comment;
              italic = false;
            };

            # ===== 关键字 =====
            Keyword = {
              fg = vscodeColors.keyword;
            };

            # ===== static =====
            StorageClass = {
              fg = vscodeColors.static;
            };

            # ===== 类 =====
            Type = {
              fg = vscodeColors.type;
            };

            # ===== 类成员 =====
            Field = {
              fg = vscodeColors.type;
            };

            Property = {
              fg = vscodeColors.type;
            };

            # ===== 函数 =====
            Function = {
              fg = vscodeColors.function;
            };

            # ===== 错误 =====
            DiagnosticError = {
              fg = vscodeColors.error;
              bold = true;
            };

            # ===== 字符串 =====
            String = {
              fg = vscodeColors.string;
            };

            # ===== 常量 =====
            Constant = {
              fg = vscodeColors.static;
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
            comments = italicStyle;
            functions = boldStyle;
            keywords = italicStyle;
            operators = boldStyle;
            conditionals = boldStyle;
            loops = boldStyle;
            booleans = [
              bold
              italic
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
                errors = italicStyle;
                hints = italicStyle;
                warnings = italicStyle;
                information = italicStyle;
              };
              underlines = {
                errors = underlineStyle;
                hints = underlineStyle;
                warnings = underlineStyle;
                information = underlineStyle;
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
    files = {
      "ftplugin/nix.lua" = {
        opts = {
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
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
          settings.event = vimEnter;
        };
      };
      which-key = {
        enable = true;
        settings = {
          delay = 0;
        };
        lazyLoad = {
          enable = true;
          settings.keys = [ leaderKey ];
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
        lazyLoad = vimEnterLazyLoad;
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
        lazyLoad = insertEnterLazyLoad;
      };
      blink-cmp = {
        enable = true;
        setupLspCapabilities = true;
        keymap = {
          preset = "default";
          # "<A-y>".__raw = ''
          #   require('minuet').make_blink_map()
          # '';
        };
        settings = {
          cmdline = {
            completion = {
              list.selection = {
                preselect = true;
              };
              menu.auto_show = true;
            };
          };
          appearance = {
            nerd_font_variant = "mono";
          };
          completion = {
            accept.auto_brackets = {
              override_brackets_for_filetypes = {
                lua = [
                  "{"
                  "}"
                ];
                nix = [
                  "{"
                  "}"
                ];
              };
            };
            documentation = {
              auto_show = false;
              auto_show_delay_ms = 500;
            };
            ghost_text = {
              enabled = true;
              # show_with_menu = false;
            };
            trigger = {
              prefetch_on_insert = true;
              show_on_backspace = true;
              # Disabled: Prefer manual completion control with <C-.>
              # Uncomment to auto-show after typing these characters:
              # show_on_x_blocked_trigger_characters = [
              #   " "
              #   ";"
              # ];
            };
            menu = {
              # border = "rounded";
              direction_priority.__raw = ''
                function()
                  local ctx = require('blink.cmp').get_context()
                  local item = require('blink.cmp').get_selected_item()
                  if ctx == nil or item == nil then return { 's', 'n' } end

                  local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
                  local is_multi_line = item_text:find('\n') ~= nil

                  -- after showing the menu upwards, we want to maintain that direction
                  -- until we re-open the menu, so store the context id in a global variable
                  if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                    vim.g.blink_cmp_upwards_ctx_id = ctx.id
                    return { 'n', 's' }
                  end
                  return { 's', 'n' }
                end
              '';

              draw = {
                snippet_indicator = "◦";
                treesitter = [ "lsp" ];
                columns.__raw = ''
                  function()
                    return {
                      { "label" },
                      { "kind_icon", "kind", gap = 1 },
                      { "source_name", gap = 1 }
                    }
                  end
                '';

                components = {
                  kind_icon = {
                    ellipsis = false;
                    text.__raw = ''
                      function(ctx)
                        local icon = ctx.kind_icon
                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                            local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                            if dev_icon then
                                icon = dev_icon
                            end
                        else
                            icon = require("lspkind").symbol_map[ctx.kind] or ""
                        end

                        return icon .. ctx.icon_gap
                      end
                    '';
                    highlight.__raw = ''
                      function(ctx)
                        local hl = ctx.kind_hl
                        if vim.tbl_contains({ "Path" }, ctx.source_name) then
                          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                          if dev_icon then
                            hl = dev_hl
                          end
                        end
                        return hl
                      end
                    '';
                  };
                };
              };
            };
          };
          fuzzy = {
            implementation = "rust";
            sorts = [
              "exact"
              "score"
              "sort_text"
            ];
            prebuilt_binaries = {
              download = false;
            };
          };
          sources = {
            default.__raw = ''
              function(ctx)
                local success, node = pcall(vim.treesitter.get_node)
                local common = { 'buffer' }
                if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                  return common
                elseif vim.bo.filetype == 'lua' then
                  return vim.list_extend({ 'lsp', 'path' }, common)
                else
                  return vim.list_extend({ 'lsp', 'path', 'snippets' }, common)
                end
              end
            '';
            providers = {
              # copilot = {
              #   name = "copilot";
              #   module = "blink-cmp-copilot";
              #   score_offset = 100;
              #   async = true;
              #   transform_items.__raw = ''
              #     function(_, items)
              #       local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              #       local kind_idx = #CompletionItemKind + 1
              #       CompletionItemKind[kind_idx] = "Copilot"
              #       for _, item in ipairs(items) do
              #         item.kind = kind_idx
              #       end
              #       return items
              #     end
              #   '';
              # };
              # minuet = {
              #   name = "minuet";
              #   module = "minuet.blink";
              #   async = true;
              #   timeout_ms = 3000;
              #   score_offset = 50;
              # };
              buffer = {
                score_offset = -7;
                opts = {
                  get_bufnrs.__raw = ''
                    function()
                      return vim.tbl_filter(function(bufnr)
                        return vim.bo[bufnr].buftype == ${"''"}
                      end, vim.api.nvim_list_bufs())
                    end
                  '';
                };
              };
              # https://cmp.saghen.dev/configuration/sources.html#show-buffer-completions-with-lsp
              lsp = {
                fallbacks = [ ];
              };
              path = {
                opts = {
                  get_cwd.__raw = ''
                    function(_)
                      return vim.fn.getcwd()
                    end
                  '';
                };
              };
            };
          };
        };
        lazyLoad = {
          enable = true;
          settings.event = [
            insertEnter
            cmdlineEnter
          ];
        };
      };
      blink-cmp-copilot = {
        enable = false;
      };
      copilot-lua = {
        enable = false;
        panel = {
          enabled = false;
          auto_refresh = true;
        };
        suggestion = {
          enabled = false;
          auto_trigger = false;
          debounce = 90;
          hide_during_completion = false;
          keymap = {
            accept_line = false;
            accept_word = false;
          };
        };
      };
      minuet = {
        enable = false;
        settings = {
          provider = "openai_compatible";
          provider_options = {
            openai_compatible = {
              api_key = "";
              end_point = "https://open.bigmodel.cn/api/coding/paas/v4";
              model = "glm-5";
              name = "GLM";
              optional = {
                max_tokens = 256;
                top_p = 0.9;
              };
              stream = true;
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
            bash = shfmtFormatter;
            zsh = shfmtFormatter;
            sh = shfmtFormatter;
            c = clangFormatFormatter;
            cpp = clangFormatFormatter;
            cmake = [ "cmake-format" ];
            html = xmlstarletFormatter;
            xml = xmlstarletFormatter;
            rust = singleCommand "rustfmt";
            lua = singleCommand "stylua";
            json = singleCommand "jq";
            nix = singleCommand "nixfmt";
          };
          formatters = {
            nixfmt = {
              command = "nixfmt";
              # args = [
              #     "--indent=4"
              #     "--width=140" # because my Xiaomi Monitor can show 140 characters
              # ];
            };
          };
        };
        lazyLoad = {
          enable = true;
          settings = {
            cmd = "ConformInfo";
            event = bufWritePre;
            keys = [
              {
                __unkeyed-1 = leader "cb";
                __unkeyed-2.__raw = ''
                  function()
                      require('conform').format { async = true, lsp_format = 'fallback' }
                  end
                '';
                mode = normalMode;
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
        lazyLoad = vimEnterLazyLoad;
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
          settings.event = [ lspAttach ];
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
        lazyLoad = vimEnterLazyLoad;
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
        lazyLoad = vimEnterLazyLoad;
      };
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
      };
      todo-comments = {
        enable = true;
        lazyLoad = vimEnterLazyLoad;
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
        lazyLoad = vimEnterLazyLoad;
      };
      fidget = {
        enable = true;
        lazyLoad = vimEnterLazyLoad;
      };
      rainbow-delimiters = {
        enable = true;
        lazyLoad = vimEnterLazyLoad;
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
      image = {
        enable = true;
        settings = {
          backend = "sixel";
          processor = "magick_cli";
          integrations = {
            markdown = {
              enabled = true;
              download_remote_images = true;
              only_render_image_at_cursor = true;
              only_render_image_at_cursor_mode = "popup";
              floating_windows = false;
              resolve_image_path.__raw = ''
                function(document_path, image_path, fallback)
                  local decoded = image_path:gsub("%%(%x%x)", function(hex)
                    return string.char(tonumber(hex, 16))
                  end)

                  return fallback(document_path, decoded)
                end
              '';
            };
            typst.enabled = true;
            neorg.enabled = true;
            syslang.enabled = true;
            html.enabled = false;
            css.enabled = false;
          };
          max_height = 12;
          max_height_window_percentage = {
            __raw = "math.huge";
          };
          max_width = 100;
          max_width_window_percentage = {
            __raw = "math.huge";
          };
          window_overlap_clear_enabled = true;
          window_overlap_clear_ft_ignore = [
            "cmp_menu"
            "cmp_docs"
            ""
          ];
        };
      };
      render-markdown = {
        enable = true;
      };
      web-devicons = {
        enable = true;
      };
      lspkind = {
        enable = true;
      };
    };
    extraFiles."after/ftplugin/markdown.lua".text = ''
      local function decode_uri_path(path)
        return path:gsub("%%(%x%x)", function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end

      local function open_markdown_link_under_cursor()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2] + 1

        for start_pos, whole_link, raw_target in line:gmatch("()(!?%[[^%]]*%]%(([^%)]+)%))") do
          local end_pos = start_pos + #whole_link - 1

          if col >= start_pos and col <= end_pos then
            local target = raw_target:match("^%s*<([^>]+)>")
              or raw_target:match("^%s*([^%s]+)")

            if not target or target == "" then
              break
            end

            local is_url = target:match("^%a[%w+.-]*://")

            if not is_url then
              target = decode_uri_path(target)

              if not target:match("^/") then
                local base = vim.fn.expand("%:p:h")
                target = vim.fn.fnamemodify(base .. "/" .. target, ":p")
              end
            end

            local opener
            if vim.fn.has("mac") == 1 then
              opener = "open"
            elseif vim.fn.has("win32") == 1 then
              opener = "explorer"
            else
              opener = "xdg-open"
            end

            vim.fn.jobstart({ opener, target }, { detach = true })
            return
          end
        end

        vim.cmd("normal! gx")
      end

      vim.keymap.set("n", "gx", open_markdown_link_under_cursor, {
        buffer = true,
        desc = "Open markdown link relative to current file",
      })
    '';
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
      require("vim._core.ui2").enable({})
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
              gitRootMarker
            ];
            filetypes = singleFiletype "lua";
          };
        };
        clangd = {
          enable = true;
          config = {
            cmd = singleCommand "clangd";
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
              gitRootMarker
            ];
          };
        };
        nixd = {
          enable = true;
          config = {
            cmd = singleCommand "nixd";
            filetypes = singleFiletype "nix";
          };
        };
        rust_analyzer = {
          enable = true;
          config = {
            cmd = singleCommand "rust-analyzer";
            filetypes = singleFiletype "rust";
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
                              or vim.fs.dirname(vim.fs.find("${gitRootMarker}", { path = fname, upward = true })[1])
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
            root_markers = [ gitRootMarker ];
          };
        };
        gopls = {
          enable = true;
          config = {
            cmd = singleCommand "gopls";
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
                      return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '${gitRootMarker}')
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
        yamlls = {
          enable = true;
          config = {
            cmd = [
              "yaml-language-server"
              "--stdio"
            ];
            filetypes = [
              "yaml"
              "yaml.docker-compose"
              "yaml.gitlab"
              "yaml.helm-values"
            ];
            root_markers = [ gitRootMarker ];
            settings = {
              redhat.telemetry.enabled = false;
              yaml.format.enable = true;
            };
            on_init.__raw = ''
              function(client)
                  client.server_capabilities.documentFormattingProvider = true
              end
            '';
          };
        };
      };
    };
  };
}
