{ ... }: {
  plugins = {
    lualine = {
      enable = true;
      luaConfig.post = "require('spreadconfig.statusline')()";
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
    };
  };
  extraFiles."lua/spreadconfig/statusline.lua".source = ../lua/statusline.lua;
}
