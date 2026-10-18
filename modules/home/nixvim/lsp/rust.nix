{ ... }: {
  lsp.servers = {
    rust_analyzer = {
      enable = true;
      activate = false;
      package = null;
      config = {
        cmd = [ "rust-analyzer" ];
        filetypes = [ "rust" ];
        root_dir.__raw = "require('spreadconfig.lsp.rust-root')";
        capabilities = {
          experimental = {
            serverStatusNotification = true;
          };
        };
        before_init.__raw = "require('spreadconfig.lsp.rust').before_init";
        on_attach.__raw = "require('spreadconfig.lsp.rust').on_attach";
      };
    };
  };
  extraFiles."lua/spreadconfig/lsp/rust-root.lua".source = ../lua/lsp/rust-root.lua;
  extraFiles."lua/spreadconfig/lsp/rust.lua".source = ../lua/lsp/rust.lua;
}
