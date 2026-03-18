{
    theme_background,
    theme_bright_dark,
    theme_white,
    theme_bright_red,
    theme_bright_background,
    theme_blue,
    theme_bright_blue,
    theme_bright_white,
    fontFamilies,
    fontSizes,
    ...
}:

{
    programs.wayprompt = {
        enable = true;
        settings = {
            general = {
                font-regular = "${fontFamilies.sans}:size=${toString fontSizes.wayprompt}";
                pin-square-amount = 32;
                border = 1;
                pin-square-border = 2;
                corner-radius = 0;
            };
            colours = {
                background = "${theme_background}cc";
                border = "${theme_bright_dark}ff";
                text = "${theme_white}ff";
                error-text = "${theme_bright_red}ff";

                # =========================
                # PIN
                # =========================

                pin-background = "${theme_bright_background}cc";
                pin-border = "${theme_bright_dark}ff";
                pin-square = "${theme_bright_background}cc";

                # =========================
                # OK button (primary)
                # =========================

                ok-button = "${theme_blue}cc";
                ok-button-border = "${theme_bright_blue}ff";
                ok-button-text = "${theme_bright_white}ff";

                # =========================
                # NOT OK (secondary)
                # =========================

                not-ok-button = "${theme_bright_background}cc";
                not-ok-button-border = "${theme_bright_dark}ff";
                not-ok-button-text = "${theme_white}ff";

                # =========================
                # Cancel (low emphasis)
                # =========================

                cancel-button = "${theme_bright_background}cc";
                cancel-button-border = "${theme_bright_dark}ff";
                cancel-button-text = "${theme_bright_dark}ff";
            };
        };
    };
}
