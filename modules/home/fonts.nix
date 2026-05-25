{ fontFallbacks, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      antialiasing = true; # setting this to true cause mako cannot display emoji
      subpixelRendering = "rgb";
      defaultFonts = {
        emoji = fontFallbacks.emoji;
        # emoji = [ "OpenMoji Color" ];
        monospace = fontFallbacks.monospace;
        sansSerif = fontFallbacks.sansSerif;
        serif = fontFallbacks.serif;
      };
    };
  };
}
