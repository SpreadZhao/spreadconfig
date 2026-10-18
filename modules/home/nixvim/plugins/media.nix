{ ... }: {
  plugins = {
    image = {
      enable = true;
      settings = {
        backend = "sixel";
        processor = "magick_cli";
        integrations = {
          markdown = {
            enabled = true;
            download_remote_images = true;
            only_render_image_at_cursor = true;
            only_render_image_at_cursor_mode = "popup";
            floating_windows = false;
            resolve_image_path.__raw = ''
              function(document_path, image_path, fallback)
                local decoded = image_path:gsub("%%(%x%x)", function(hex)
                  return string.char(tonumber(hex, 16))
                end)

                return fallback(document_path, decoded)
              end
            '';
          };
          typst.enabled = true;
          neorg.enabled = true;
          syslang.enabled = true;
          html.enabled = false;
          css.enabled = false;
        };
        max_height = 12;
        max_height_window_percentage = {
          __raw = "math.huge";
        };
        max_width = 100;
        max_width_window_percentage = {
          __raw = "math.huge";
        };
        window_overlap_clear_enabled = true;
        window_overlap_clear_ft_ignore = [
          "cmp_menu"
          "cmp_docs"
          ""
        ];
      };
    };
    render-markdown = {
      enable = true;
    };
  };
  extraFiles."after/ftplugin/markdown.lua".text = "require('spreadconfig.markdown')()";
  extraFiles."lua/spreadconfig/markdown.lua".source = ../lua/markdown.lua;

}
