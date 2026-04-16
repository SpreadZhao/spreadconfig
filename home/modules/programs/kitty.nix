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
    settings = {
      font_family = "family='${fontFamilies.mono}' features='cv01=1 cv03=1 cv07=1 cv09=1 cv10=1 cv66=1 +ss03 +ss10'";
      bold_font = "family='${fontFamilies.mono}' style='Bold' features='cv01=1 cv03=1 cv07=1 cv09=1 cv10=1 cv66=1 +ss03 +ss10'";
      italic_font = "family='${fontFamilies.mono}' style='Italic' features='cv01=1 cv66=1 +ss03 +ss10 cv40=1 cv42=1 cv43=1'";
      bold_italic_font = "family='${fontFamilies.mono}' style='Bold Italic' features='cv01=1 cv66=1 +ss03 +ss10 cv40=1 cv42=1 cv43=1'";
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
      enable_audio_bell = false;
    };

  };
}
