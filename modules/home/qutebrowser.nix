{
  config,
  hostConfigSource,
  hostName,
  lib,
  pkgs,
  ...
}:

let
  qutebrowserDesktopExec = "Exec=env QT_SCALE_FACTOR=1.5 qutebrowser";
  qutebrowserBasePackage = (
    (pkgs.qutebrowser.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
          --replace-fail "Exec=qutebrowser" ${lib.escapeShellArg qutebrowserDesktopExec}
      '';
    })).override
      {
        enableWideVine = true;
      }
  );

  qutebrowserPackage =
    if hostName == "zephyrus-m16" then
      pkgs.symlinkJoin {
        name = "qutebrowser-nvidia";
        paths = [ qutebrowserBasePackage ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/qutebrowser \
            --set QT_SCALE_FACTOR 1.5 \
            --set __NV_PRIME_RENDER_OFFLOAD 1 \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
            --set __GLX_VENDOR_LIBRARY_NAME nvidia \
            --set __VK_LAYER_NV_optimus NVIDIA_only
        '';
      }
    else
      qutebrowserBasePackage;
in

{
  home.packages = [ qutebrowserPackage ];

  xdg.configFile."qutebrowser/quickmarks".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.password-store/qutebrowser/qutebrowser_quickmarks";
  xdg.configFile."qutebrowser/config.py".source = hostConfigSource "qutebrowser/config.py";
  xdg.configFile."qutebrowser/themes".source = hostConfigSource "qutebrowser/themes";
}
