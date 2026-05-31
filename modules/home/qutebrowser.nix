{
  config,
  hostConfigSource,
  lib,
  pkgsPinned,
  secretsDir,
  ...
}:

let
  qutebrowserDesktopExec = "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser";
in

{
  home.packages = [
    (
      (pkgsPinned.old_a6c3b1b.qutebrowser.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
            --replace-fail "Exec=qutebrowser" ${lib.escapeShellArg qutebrowserDesktopExec}
        '';
      })).override
      {
        enableWideVine = true;
      }
    )
  ];

  xdg.configFile."qutebrowser/quickmarks".source =
    config.lib.file.mkOutOfStoreSymlink "${secretsDir}/qutebrowser_quickmarks";
  xdg.configFile."qutebrowser/config.py".source = hostConfigSource "qutebrowser/config.py";
  xdg.configFile."qutebrowser/themes".source = hostConfigSource "qutebrowser/themes";
}
