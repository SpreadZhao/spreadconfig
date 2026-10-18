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

let
  desktopEntry =
    pkgs.runCommand "qutebrowser-desktop-entry"
      {
        nativeBuildInputs = [ pkgs.desktop-file-utils ];
      }
      ''
        mkdir -p "$out/share/applications"
        desktop="$out/share/applications/org.qutebrowser.qutebrowser.desktop"
        substitute ${config.programs.qutebrowser.package}/share/applications/org.qutebrowser.qutebrowser.desktop "$desktop" \
          --replace-fail 'Exec=qutebrowser' 'Exec=env QT_SCALE_FACTOR=1.5 qutebrowser'
        desktop-file-validate "$desktop"
      '';
in
{
  imports = [ ./scripts.nix ];

  programs.qutebrowser.package = lib.mkDefault (import ./package.nix { inherit lib pkgs; });

  home.packages = [
    config.programs.qutebrowser.package
    (lib.hiPrio desktopEntry)
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
