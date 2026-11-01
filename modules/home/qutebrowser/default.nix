{
  config,
  appEntries,
  appSource,
  repoLink,
  repoTree,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./scripts.nix ];

  programs.qutebrowser.package = lib.mkDefault (import ./package.nix { inherit lib pkgs; });

  home.packages = [
    config.programs.qutebrowser.package
    pkgs.jq
  ];

  xdg = {
    mimeApps.defaultApplications = lib.genAttrs [
      "application/xhtml+xml"
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/qute"
      "x-scheme-handler/unknown"
    ] (_: "org.qutebrowser.qutebrowser.desktop");

    dataFile."qutebrowser/userscripts/translate".source = repoLink (
      appSource "qutebrowser" "scripts/qutebrowser/translate"
    );
    configFile = {
      "qutebrowser/quickmarks".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.password-store/qutebrowser/qutebrowser_quickmarks";
      "qutebrowser/config.py".source = repoLink (appSource "qutebrowser" "files/config.py");
      "qutebrowser/host.py".source = repoLink (appSource "qutebrowser" "files/host.py");
      "qutebrowser/themes".source = repoTree "qutebrowser-themes" (
        appEntries "qutebrowser" "files/themes"
      );
    };
  };
}
