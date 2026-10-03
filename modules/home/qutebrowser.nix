{
  config,
  hostConfigSource,
  hostScriptSource,
  host,
  lib,
  pkgs,
  ...
}:

let
  qutebrowserProfile = host.profile.home.qutebrowser;
  scaleFactor = builtins.toJSON qutebrowserProfile.scaleFactor;
  useIntelVulkan = host.gpu.hasNvidia && qutebrowserProfile.renderer == "intel-vulkan";
  qutebrowserDesktopExec = "Exec=env QT_SCALE_FACTOR=${scaleFactor} qutebrowser";
  qutebrowserBasePackage =
    (pkgs.qutebrowser.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        substituteInPlace $out/share/applications/org.qutebrowser.qutebrowser.desktop \
          --replace-fail "Exec=qutebrowser" ${lib.escapeShellArg qutebrowserDesktopExec}
      '';
    })).override
      {
        enableWideVine = true;
      };

  # NVIDIA hosts with the Intel Vulkan policy run on their Intel iGPU.
  # QtWebEngine defaults to a Vulkan compositing backend and its adapter
  # selection prefers the discrete GPU,
  # landing on the NVIDIA 595 driver whose vkQueueSubmit segfaults on
  # livestream video (disabling Vulkan instead renders black pages on
  # NVIDIA). Hide every other Vulkan ICD so only the Intel device exists.
  intelVkIcd = "${pkgs.mesa.driverLink}/share/vulkan/icd.d/intel_icd.x86_64.json";
  qutebrowserPackage =
    if useIntelVulkan then
      pkgs.symlinkJoin {
        name = "qutebrowser-intel-vulkan";
        paths = [ qutebrowserBasePackage ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/qutebrowser \
            --set QT_SCALE_FACTOR ${lib.escapeShellArg scaleFactor} \
            --set VK_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd} \
            --set VK_LOADER_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd}
        '';
      }
    else
      qutebrowserBasePackage;
in

{
  assertions = [
    {
      assertion =
        qutebrowserProfile.renderer != "intel-vulkan" || (host.gpu.hasNvidia && host.gpu.hasIntel);
      message = "The qutebrowser Intel Vulkan workaround requires both NVIDIA and Intel GPUs on ${host.name}.";
    }
  ];

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
