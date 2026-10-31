{ inputs, pkgs, ... }:

let
  packages = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    packages.google-antigravity
    packages.google-antigravity-cli
  ];

  xdg.desktopEntries.antigravity = {
    name = "Google Antigravity";
    comment = "Next-generation agentic IDE";
    exec = "${packages.google-antigravity}/bin/antigravity --password-store=basic %U";
    icon = "antigravity";
    categories = [
      "Development"
      "IDE"
    ];
    mimeType = [ "x-scheme-handler/antigravity" ];
    startupNotify = true;
    settings.StartupWMClass = "Antigravity";
  };

  xdg.mimeApps = {
    defaultApplications."x-scheme-handler/antigravity" = "antigravity.desktop";
    associations.added."x-scheme-handler/antigravity" = "antigravity.desktop";
  };
}
