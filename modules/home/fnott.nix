{
  config,
  pkgs,
  theme_background,
  theme_yellow,
  theme_bright_white,
  theme_white,
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
    # The package activation file duplicates Home Manager's and has the wrong name.
    package = pkgs.fnott.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm "$out/share/dbus-1/services/fnott.service"
      '';
    });
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

        max-timeout = 10;
        default-timeout = 10;
        idle-timeout = 5;
      };
      critical = {
        border-color = "${theme_red}ff";
      };
    };
  };

  xdg.dataFile = {
    "dbus-1/services/fnott.service".enable = false;
    "dbus-1/services/org.freedesktop.Notifications.service".text = ''
      [D-BUS Service]
      Name=org.freedesktop.Notifications
      Exec=${config.services.fnott.package}/bin/fnott
      SystemdService=fnott.service
    '';
  };
}
