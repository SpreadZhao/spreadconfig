{ ... }: {
  lsp.servers = {
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
          ".git"
        ];
        filetypes = [ "lua" ];
      };
    };
  };
}
