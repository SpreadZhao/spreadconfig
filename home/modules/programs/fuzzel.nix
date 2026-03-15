{
    theme_radius,
    theme_background,
    theme_bright_white,
    theme_bright_dark,
    theme_yellow,
    theme_bright_background,
    theme_blue,
    ...
}:

{
    programs.fuzzel = {
        enable = true;
        settings = {
            border = {
                radius = "${theme_radius}";
            };
            colors = {
                background = "${theme_background}dd";
                text = "${theme_bright_white}ff";
                prompt = "${theme_bright_white}ff";
                placeholder = "${theme_bright_dark}ff";
                input = "${theme_bright_white}ff";
                match = "${theme_yellow}ff";
                selection = "${theme_bright_background}ff";
                selection-text = "${theme_bright_white}ff";
                selection-match = "${theme_yellow}ff";
                counter = "${theme_blue}ff";
            };
            main = {
                font = "IBM Plex Mono:size=18, Symbols Nerd Font Mono:size=18, Noto Color Emoji:size=18";
                image-size-ratio = 1;
                show-actions = "no";
                tabs = 4;
                terminal = "footclient -a '{cmd}' -T '{cmd}' {cmd}";
                use-bold = "yes";
                width = 50;
            };
            key-bindings = {
                "next" = "none";
                "prev" = "none";
                next-with-wrap = "Control+n";
                prev-with-wrap = "Control+p";
            };
        };
    };
}
