{
    pkgs,
    fontFamilies,
    fontSizes,
    ...
}:

{
    gtk = {
        enable = true;
        colorScheme = "dark";
        # theme = {
        #     name = "catppuccin-mocha-rosewater-compact+default";
        #     package =
        #         (pkgs.catppuccin-gtk.overrideAttrs {
        #             src = pkgs.fetchFromGitHub {
        #                 owner = "catppuccin";
        #                 repo = "gtk";
        #                 rev = "v1.0.3";
        #                 fetchSubmodules = true;
        #                 hash = "sha256-q5/VcFsm3vNEw55zq/vcM11eo456SYE5TQA3g2VQjGc=";
        #             };
        #
        #             postUnpack = "";
        #         }).override
        #             {
        #                 accents = [ "rosewater" ];
        #                 variant = "mocha";
        #                 size = "compact";
        #             };
        # };
        cursorTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
            size = 36;
        };
        font = {
            # name = "Noto Sans";
            name = fontFamilies.sans;
            size = fontSizes.gtk;
        };
        gtk3 = {
            enable = true;
        };
        gtk4.enable = true;
    };
}
