{ lib, ... }: {
  plugins = {
    nvim-autopairs = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.event = "InsertEnter";
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
    nvim-surround = {
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
  };
  extraConfigVim = lib.mkAfter ''
    let g:qs_highlight_on_keys = ['f', 'F']
    highlight QuickScopePrimary guifg='#ff0000' gui=bold,underline ctermfg=red cterm=bold,underline
    highlight QuickScopeSecondary guifg='#00ff00' gui=underline ctermfg=yellow cterm=underline
  '';

}
