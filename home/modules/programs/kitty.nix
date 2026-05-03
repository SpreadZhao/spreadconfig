{
  theme_background,
  theme_red,
  theme_green,
  theme_yellow,
  theme_blue,
  theme_magenta,
  theme_cyan,
  theme_white,
  theme_bright_dark,
  theme_bright_blue,
  fontFamilies,
  fontSizes,
  ...
}:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    keybindings =  {
      "ctrl+alt+shift+n" = "new_os_window_with_cwd";
      "ctrl+alt+shift+t" = "new_tab_with_cwd";
    };
    settings = {
      font_family = "family='${fontFamilies.mono}'";
      bold_font = "family='${fontFamilies.mono}' style='Bold'";
      italic_font = "family='${fontFamilies.mono}' style='Italic'";
      bold_italic_font = "family='${fontFamilies.mono}' style='Bold Italic'";
      font_size = fontSizes.kitty;
      disable_ligatures = "cursor";

      background = "#${theme_background}";
      foreground = "#${theme_white}";
      cursor = "#${theme_white}";

      color0 = "#${theme_background}";
      color1 = "#${theme_red}";
      color2 = "#${theme_green}";
      color3 = "#${theme_yellow}";
      color4 = "#${theme_blue}";
      color5 = "#${theme_magenta}";
      color6 = "#${theme_cyan}";
      color7 = "#${theme_white}";
      color8 = "#${theme_bright_dark}";
      color9 = "#ff6b6b";
      color10 = "#b4cda8";
      color11 = "#d7ba7d";
      color12 = "#${theme_bright_blue}";
      color13 = "#e49ad8";
      color14 = "#5fe0c6";
      color15 = "#ffffff";

      touch_scroll_multiplier = 3.0;

      selection_foreground = "#adaeac";
      selection_background = "#264e77";

      url_color = "#47a2ed";

      scrollback_lines = 10000;
      scrollback_pager = "nvim --cmd 'set eventignore=FileType' +'nnoremap q ZQ' +'call nvim_open_term(0, {})' +'set nomodified nolist' +'$' -";
      enable_audio_bell = false;
    };

  };
}
