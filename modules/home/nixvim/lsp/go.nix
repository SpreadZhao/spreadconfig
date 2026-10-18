{ pkgs, ... }: {
  lsp.servers = {
    gopls = {
      enable = true;
      activate = false;
      package = null;
      config = {
        cmd = [ "gopls" ];
        filetypes = [
          "go"
          "gomod"
          "gowork"
          "gotmpl"
        ];
        root_dir.__raw = ''
          require('spreadconfig.lsp.go')("${pkgs.vimPlugins.nvim-lspconfig}/lsp/gopls.lua")
        '';
      };
    };
  };
  extraFiles."lua/spreadconfig/lsp/go.lua".source = ../lua/lsp/go.lua;
}
