{ ... }: {
  plugins = {
    oil = {
      enable = true;
      settings = {
        colums = [ "icon" ];
        delete_to_trash = true;
        cleanup_delay_ms = 10000;
      };
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
    };
    which-key = {
      enable = true;
      settings = {
        delay = 0;
      };
      lazyLoad = {
        enable = true;
        settings.keys = [ "<leader>" ];
      };
    };
    flash = {
      enable = true;
      settings = {
        labels = "asdfghjklqwertyuiopzxcvbnm";
        label = {
          uppercase = false;
          rainbow.enabled = false;
        };
        modes = {
          search.enabled = false;
          char.enabled = false;
        };
      };
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
    };
    fzf-lua = {
      enable = true;
      settings = {
        winopts = {
          fullscreen = true;
          preview = {
            vertical = "up:65%";
            layout = "vertical";
          };
        };
      };
      lazyLoad = {
        enable = false;
        settings.event = [ "LspAttach" ];
      };
    };
    toggleterm = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings = {
          cmd = "ToggleTerm";
        };
      };
    };
  };

}
