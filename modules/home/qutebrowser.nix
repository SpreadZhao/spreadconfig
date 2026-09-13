{
  config,
  hostConfigSource,
  hostScriptSource,
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

  # zephyrus-m16: run on the Intel iGPU. QtWebEngine defaults to a Vulkan
  # compositing backend and its adapter selection prefers the discrete GPU,
  # landing on the NVIDIA 595 driver whose vkQueueSubmit segfaults on
  # livestream video (disabling Vulkan instead renders black pages on
  # NVIDIA). Hide every other Vulkan ICD so only the Intel device exists.
  intelVkIcd = "${pkgs.mesa.driverLink}/share/vulkan/icd.d/intel_icd.x86_64.json";
  qutebrowserPackage =
    if hostName == "zephyrus-m16" then
      pkgs.symlinkJoin {
        name = "qutebrowser-zephyrus";
        paths = [ qutebrowserBasePackage ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/qutebrowser \
            --set QT_SCALE_FACTOR 1.5 \
            --set VK_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd} \
            --set VK_LOADER_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd}
        '';
      }
    else
      qutebrowserBasePackage;
in

{
  home.packages = [
    qutebrowserPackage
    pkgs.jq
  ];

  xdg.dataFile."qutebrowser/userscripts/translate".source = hostScriptSource "qutebrowser/translate";
  xdg.configFile."qutebrowser/quickmarks".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.password-store/qutebrowser/qutebrowser_quickmarks";
  xdg.configFile."qutebrowser/config.py".source = hostConfigSource "qutebrowser/config.py";
  xdg.configFile."qutebrowser/themes".source = hostConfigSource "qutebrowser/themes";
}
