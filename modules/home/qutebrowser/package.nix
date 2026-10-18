{
  lib,
  pkgs,
  scaleFactor ? 1.5,
  intelVulkan ? false,
}:

let
  scale = builtins.toJSON scaleFactor;
  qutebrowserDesktopExec = "Exec=env QT_SCALE_FACTOR=${scale} qutebrowser";
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

  # Restrict Vulkan to Intel: QtWebEngine otherwise prefers the NVIDIA 595
  # device, where vkQueueSubmit crashes on livestreams. Disabling Vulkan
  # produces black pages, so keep Vulkan enabled on the Intel GPU.
  intelVkIcd = "${pkgs.mesa.driverLink}/share/vulkan/icd.d/intel_icd.x86_64.json";
  qutebrowserPackage =
    if intelVulkan then
      pkgs.symlinkJoin {
        name = "qutebrowser-intel-vulkan";
        paths = [ qutebrowserBasePackage ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/qutebrowser \
            --set QT_SCALE_FACTOR ${lib.escapeShellArg scale} \
            --set VK_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd} \
            --set VK_LOADER_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd}
        '';
      }
    else
      qutebrowserBasePackage;
in
qutebrowserPackage
