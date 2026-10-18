{ ... }: {
  lsp.servers = {
    basedpyright = {
      enable = true;
      activate = false;
      package = null;
      config = {
        cmd = [
          "basedpyright-langserver"
          "--stdio"
        ];
        filetypes = [ "python" ];
        root_markers = [
          "pyproject.toml"
          "setup.py"
          "setup.cfg"
          "requirements.txt"
          "Pipfile"
          "pyrightconfig.json"
          ".git"
        ];
      };
    };
  };
}
