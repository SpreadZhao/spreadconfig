{
  lib,
  pkgs,
  intelVulkan ? false,
}:

let
  qutebrowserBasePackage = pkgs.qutebrowser.override {
    enableWideVine = true;
  };

  # Restrict Vulkan to Intel: QtWebEngine otherwise prefers the NVIDIA 595
  # device, where vkQueueSubmit crashes on livestreams. Disabling Vulkan
  # produces black pages, so keep Vulkan enabled on the Intel GPU.
  intelVkIcd = "${pkgs.mesa.driverLink}/share/vulkan/icd.d/intel_icd.x86_64.json";
in
if intelVulkan then
  pkgs.symlinkJoin {
    name = "qutebrowser-intel-vulkan";
    paths = [ qutebrowserBasePackage ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/qutebrowser \
        --set VK_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd} \
        --set VK_LOADER_ICD_FILENAMES ${lib.escapeShellArg intelVkIcd}
    '';
  }
else
  qutebrowserBasePackage
