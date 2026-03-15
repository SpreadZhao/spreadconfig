{ ... }:

{
    fonts = {
        fontconfig = {
            enable = true;
            antialiasing = true; # setting this to true cause mako cannot display emoji
            subpixelRendering = "rgb";
            defaultFonts = {
                emoji = [ "Noto Color Emoji" ];
                # emoji = [ "OpenMoji Color" ];
                monospace = [
                    "IBM Plex Mono"
                    "Noto Sans Mono"
                    "Noto Sans Mono CJK SC"
                    "Noto Sans Mono CJK HK"
                    "Noto Sans Mono CJK TC"
                    "Noto Sans Mono CJK JP"
                    "Noto Sans Mono CJK KR"
                    "Symbols Nerd Font Mono"
                    # "Noto Color Emoji"
                ];
                sansSerif = [
                    "IBM Plex Sans"
                    "IBM Plex Sans SC"
                    "IBM Plex Sans TC"
                    "IBM Plex Sans JP"
                    "IBM Plex Sans KR"
                    "IBM Plex Sans Thai"
                    "IBM Plex Sans Thai Looped"
                    "IBM Plex Sans Hebrew"
                    "IBM Plex Sans Arabic"
                    "IBM Plex Sans Devanagari"
                    "Noto Sans"
                    "Noto Sans CJK SC"
                    "Noto Sans CJK HK"
                    "Noto Sans CJK TC"
                    "Noto Sans CJK JP"
                    "Noto Sans CJK KR"
                    # "Noto Color Emoji"
                ];
                serif = [
                    "IBM Plex Serif"
                    "Noto Serif"
                    "Noto Serif CJK SC"
                    "Noto Serif CJK HK"
                    "Noto Serif CJK TC"
                    "Noto Serif CJK JP"
                    "Noto Serif CJK KR"
                    # "Noto Color Emoji"
                ];
            };
        };
    };
}
