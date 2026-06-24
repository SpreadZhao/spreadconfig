{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.spreadzhao.proxyApp;

  proxyApps = {
    clash-verge-rev = {
      package = pkgs.clash-verge-rev;
      desktopEntry = "${pkgs.clash-verge-rev}/share/applications/clash-verge.desktop";
    };
    flclash = {
      package = pkgs.flclash;
      desktopEntry = "${pkgs.flclash}/share/applications/flclash.desktop";
    };
    nekobox = {
      package = pkgs.nekobox;
      desktopEntry = "${pkgs.nekobox}/share/applications/nekobox.desktop";
    };
  };

  selectedApp = proxyApps.${cfg.selected};
in
{
  options.spreadzhao.proxyApp.selected = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum (builtins.attrNames proxyApps));
    default = "nekobox";
    description = ''
      Proxy GUI client to install and start through XDG autostart.
      Set to null to install no proxy GUI client.
    '';
  };

  config = lib.mkIf (cfg.selected != null) {
    home.packages = [ selectedApp.package ];

    xdg.autostart.entries = [
      selectedApp.desktopEntry
    ];
  };
}
