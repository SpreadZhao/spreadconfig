{ ... }: {
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
  files = {
    "ftplugin/nix.lua" = {
      opts = {
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
      };
    };
  };
  extraConfigLua = ''
    require("outline").setup({})
    require("vim._core.ui2").enable({})
  '';

}
