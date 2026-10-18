{ ... }: {
  plugins = {
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = {
            text = "+";
          };
          change = {
            text = "~";
          };
          delete = {
            text = "_";
          };
          topdelete = {
            text = "‾";
          };
          changedelete = {
            text = "~";
          };
        };
        on_attach = "require('spreadconfig.gitsigns')";
      };
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
    };
    lazygit = {
      enable = true;
      settings = {
        floating_window_border_chars = [
          "╭"
          "─"
          "╮"
          "│"
          "╯"
          "─"
          "╰"
          "│"
        ];
        floating_window_scaling_factor = 0.9;
        floating_window_use_plenary = 0;
        floating_window_winblend = 0;
        use_custom_config_file_path = 0;
        use_neovim_remote = 1;
      };
      # do not have in 25.11
      # lazyLoad.enable = true;
    };
  };

  extraFiles."lua/spreadconfig/gitsigns.lua".source = ../lua/gitsigns.lua;
}
