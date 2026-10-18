{ fontFallbacks, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      antialiasing = true;
      subpixelRendering = "rgb";
      defaultFonts = {
        emoji = fontFallbacks.emoji;
        monospace = fontFallbacks.monospace;
        sansSerif = fontFallbacks.sansSerif;
        serif = fontFallbacks.serif;
      };
    };
  };
}
