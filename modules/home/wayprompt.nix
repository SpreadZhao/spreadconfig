{
  inputs,
  pkgs,
  theme_background,
  theme_bright_dark,
  theme_white,
  theme_bright_red,
  theme_bright_background,
  theme_yellow,
  theme_blue,
  theme_bright_blue,
  theme_bright_white,
  theme_cyan,
  fontFamilies,
  fontSizes,
  ...
}:

let
  surface = theme_background;
  elevatedSurface = theme_bright_background;
  outline = theme_bright_dark;
  text = theme_bright_white;
  mutedText = theme_white;
  primary = theme_blue;
  primaryOutline = theme_bright_blue;
  accent = theme_cyan;
  warning = theme_yellow;
  danger = theme_bright_red;
  package = inputs.wayprompt-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.wayprompt;
in
{
  programs.wayprompt = {
    enable = true;
    inherit package;
    settings = {
      general = {
        font-regular = "${fontFamilies.sans}:size=${toString fontSizes.wayprompt}";
        pin-square-amount = 32;
        border = 1;
        pin-square-border = 2;
        corner-radius = 0;
      };
      colours = {
        background = "${surface}e6";
        border = "${outline}ff";
        text = "${text}ff";
        error-text = "${danger}ff";

        # =========================
        # PIN
        # =========================

        pin-background = "${elevatedSurface}dd";
        pin-border = "${outline}ff";
        pin-square = "${accent}e6";

        # =========================
        # OK button (primary)
        # =========================

        ok-button = "${primary}dd";
        ok-button-border = "${primaryOutline}ff";
        ok-button-text = "${text}ff";

        # =========================
        # NOT OK (secondary)
        # =========================

        not-ok-button = "${elevatedSurface}dd";
        not-ok-button-border = "${warning}ff";
        not-ok-button-text = "${text}ff";

        # =========================
        # Cancel (low emphasis)
        # =========================

        cancel-button = "${elevatedSurface}cc";
        cancel-button-border = "${outline}ff";
        cancel-button-text = "${mutedText}ff";
      };
    };
  };
}
