{ ... }: {
  plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "default";
        };
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
            direction_priority.__raw = "require('spreadconfig.completion').direction_priority";

            draw = {
              snippet_indicator = "◦";
              treesitter = [ "lsp" ];
              columns.__raw = "require('spreadconfig.completion').columns";

              components = {
                kind_icon = {
                  ellipsis = false;
                  text.__raw = "require('spreadconfig.completion').kind_icon";
                  highlight.__raw = "require('spreadconfig.completion').kind_highlight";
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
          default.__raw = "require('spreadconfig.completion').sources";
          providers = {
            buffer = {
              score_offset = -7;
              opts = {
                get_bufnrs.__raw = "require('spreadconfig.completion').buffer_bufnrs";
              };
            };
            # https://cmp.saghen.dev/configuration/sources.html#show-buffer-completions-with-lsp
            lsp = {
              fallbacks = [ ];
            };
            path = {
              opts = {
                get_cwd.__raw = "require('spreadconfig.completion').path_cwd";
              };
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
    lspkind = {
      enable = true;
    };
  };

  extraFiles."lua/spreadconfig/completion.lua".source = ../lua/completion.lua;
}
