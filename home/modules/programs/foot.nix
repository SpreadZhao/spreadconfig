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
    programs.foot = {
        enable = true;
        server.enable = true;
        settings = {
            main = {
                font = "${fontFamilies.mono}:size=${toString fontSizes.foot}, ${fontFamilies.nerdMono}:size=${toString fontSizes.foot}";
                bold-text-in-bright = "yes";
            };
            colors-dark = {
                # alpha = 0.8;

                foreground = "ffffff";
                background = "000000";
                cursor = "171616 adaeac";

                # --- ANSI 8 colors ---

                regular0 = "${theme_background}"; # black (background)
                regular1 = "${theme_red}"; # red (error)
                regular2 = "${theme_green}"; # green (comment)
                regular3 = "${theme_yellow}"; # yellow (function)
                regular4 = "${theme_blue}"; # blue (keyword)
                regular5 = "${theme_magenta}"; # magenta (secondary keyword)
                regular6 = "${theme_cyan}"; # cyan (class)
                regular7 = "${theme_white}"; # white (default text)

                # --- bright variants ---

                bright0 = "${theme_bright_dark}";
                bright1 = "ff6b6b";
                bright2 = "b4cda8";
                bright3 = "d7ba7d";
                bright4 = "${theme_bright_blue}";
                bright5 = "e49ad8";
                bright6 = "5fe0c6";
                bright7 = "ffffff";

                selection-foreground = "adaeac";
                selection-background = "264e77";

                search-box-no-match = "171616 f44747";
                search-box-match = "adaeac 262626";

                jump-labels = "171616 e6e6aa";
                urls = "47a2ed";
            };
            cursor = {
                style = "beam";
            };
            desktop-notifications = {
                command = ''notify-send --wait --app-name ''\${app-id} --icon ''\${app-id} --category ''\${category} --urgency ''\${urgency} --expire-time ''\${expire-time} --hint STRING:image-path:''\${icon} --hint BOOLEAN:suppress-sound:''\${muted} --hint STRING:sound-name:''\${sound-name} --replace-id ''\${replace-id} ''\${action-argument} --print-id -- ''\${title} ''\${body}'';
            };
            url = {
                launch = "xdg-open \${url}";
            };
            key-bindings = {
                scrollback-up-half-page = "Control+u";

                scrollback-down-half-page = "Control+d";
                search-start = "Control+f";
            };
            search-bindings = {
                find-prev = "Control+p";
                find-next = "Control+n";
            };
        };
    };
}
