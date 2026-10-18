{ ... }: {
  lsp.servers = {
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
        root_markers = [ ".git" ];
      };
    };
  };
}
