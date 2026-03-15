{
    theme_background,
    theme_tranparent,
    theme_bright_dark,
    theme_blue,
    theme_bright_yellow,
    theme_cyan,
    theme_bright_red,
    theme_white,
    theme_bright_white,
    ...
}:

{
    programs.swaylock = {
        enable = true;
        settings = {
            ignore-empty-password = true;
            show-failed-attempts = true;
            daemonize = true;

            font = "IBM Plex Sans";
            font-size = 30;

            color = "${theme_background}";

            inside-color = "${theme_tranparent}";
            inside-clear-color = "${theme_tranparent}";
            inside-caps-lock-color = "${theme_tranparent}";
            inside-ver-color = "${theme_tranparent}";
            inside-wrong-color = "${theme_tranparent}";

            line-color = "${theme_tranparent}";
            line-clear-color = "${theme_tranparent}";
            line-caps-lock-color = "${theme_tranparent}";
            line-ver-color = "${theme_tranparent}";
            line-wrong-color = "${theme_tranparent}";

            separator-color = "${theme_tranparent}";
            layout-bg-color = "${theme_tranparent}";
            layout-border-color = "${theme_tranparent}";

            # ===============================
            # Ring
            # ===============================

            ring-color = "${theme_bright_dark}"; # default: cool gray
            ring-clear-color = "${theme_blue}"; # typing: blue
            ring-caps-lock-color = "${theme_bright_yellow}";
            ring-ver-color = "${theme_cyan}"; # verifying: cyan
            ring-wrong-color = "${theme_bright_red}"; # error: bright red

            # ===============================
            # Text
            # ===============================

            text-color = "${theme_white}";
            text-clear-color = "${theme_blue}";
            text-caps-lock-color = "${theme_bright_yellow}";
            text-ver-color = "${theme_cyan}";
            text-wrong-color = "${theme_bright_red}";

            layout-text-color = "${theme_white}";

            # ===============================
            # Key feedback
            # ===============================

            key-hl-color = "${theme_white}";
            caps-lock-key-hl-color = "${theme_bright_white}";
            bs-hl-color = "${theme_blue}";
            caps-lock-bs-hl-color = "${theme_bright_yellow}";

            scaling = "fit";

            indicator-radius = 200;
            indicator-idle-visible = true;

            disable-caps-lock-text = true;
            indicator-caps-lock = true;
        };
    };
}
