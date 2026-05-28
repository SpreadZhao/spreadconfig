{
  config,
  hostConfigSource,
  hostName,
  lib,
  pkgsPinned,
  secretsDir,
  ...
}:

let
  qutebrowserDesktopExec =
    if hostName == "zephyrus-m16" then
      "Exec=env QT_SCALE_FACTOR=1.5 __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only qutebrowser"
    else
      "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser";
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
