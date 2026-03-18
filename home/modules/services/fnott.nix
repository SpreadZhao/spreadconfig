{
    theme_background,
    theme_yellow,
    theme_bright_white,
    theme_white,
    theme_bright_dark,
    theme_blue,
    theme_radius,
    theme_red,
    fontFamilies,
    fontSizes,
    ...
}:

{
    services.fnott = {
        enable = true;
        settings = {
            main = {
                layer = "overlay";
                title-color = "${theme_yellow}ff";
                summary-color = "${theme_bright_white}ff";
                body-color = "${theme_white}ff";
                background = "${theme_background}ff";
                border-color = "${theme_bright_white}ff";
                progress-color = "${theme_blue}ff";

                max-width = 1000;
                max-height = 500;
                max-icon-size = 64;
                anchor = "top-right";
                stacking-order = "bottom-up";
                selection-helper-uses-null-separator = "yes";
                selection-helper = "\"fuzzel --dmenu0\"";
                border-radius = "${theme_radius}";
                edge-margin-vertical = 0;
                edge-margin-horizontal = 0;

                dpi-aware = "yes";
                title-font = "${fontFamilies.sans}:size=${toString fontSizes.fnott.title}";
                summary-font = "${fontFamilies.sans}:size=${toString fontSizes.fnott.summary}";
                body-font = "${fontFamilies.sans}:size=${toString fontSizes.fnott.body}";

                title-format = "<b>%a%A</b>";
                summary-format = "%s";
                body-format = "%b";

                max-timeout = 0;
                default-timeout = 10;
                idle-timeout = 5;
            };
            critical = {
                border-color = "${theme_red}ff";
            };
        };
    };
}
