{
  config,
  pkgsPinned,
  spreadconfigDir,
  secretsDir,
  ...
}:

{
  home.packages = [
    (
      (pkgsPinned.old_a6c3b1b.qutebrowser.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
            --replace-fail "Exec=qutebrowser" "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser"
        '';
      })).override
      {
        enableWideVine = true;
      }
    )
  ];

  xdg.configFile."qutebrowser/quickmarks".source =
    config.lib.file.mkOutOfStoreSymlink "${secretsDir}/qutebrowser_quickmarks";
  xdg.configFile."qutebrowser/config.py".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/qutebrowser/config.py";
  xdg.configFile."qutebrowser/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${spreadconfigDir}/config/qutebrowser/themes";
}
