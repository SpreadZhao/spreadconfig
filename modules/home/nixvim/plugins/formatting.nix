{ ... }: {
  plugins = {
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
  };

}
