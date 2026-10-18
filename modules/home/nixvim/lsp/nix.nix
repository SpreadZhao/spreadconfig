{ ... }: {
  lsp.servers = {
    nixd = {
      enable = true;
      config = {
        cmd = [ "nixd" ];
        filetypes = [ "nix" ];
      };
    };
  };
}
