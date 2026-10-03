{
  config,
  repoEntries,
  repoLink,
  repoTree,
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
  imports = [ ./scripts.nix ];

  options.spreadconfig.apps.qutebrowser.hostConfig = lib.mkOption {
    type = lib.types.str;
    default = "modules/home/qutebrowser/files/host.py";
    description = "Repository-relative path to native host overrides, sourced before theme setup.";
  };

  config = {
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

    xdg = {
      dataFile."qutebrowser/userscripts/translate".source =
        repoLink "modules/home/qutebrowser/scripts/qutebrowser/translate";
      configFile = {
        "qutebrowser/quickmarks".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.password-store/qutebrowser/qutebrowser_quickmarks";
        "qutebrowser/config.py".source = repoLink "modules/home/qutebrowser/files/config.py";
        "qutebrowser/host.py".source = repoLink config.spreadconfig.apps.qutebrowser.hostConfig;
        "qutebrowser/themes".source = repoTree "qutebrowser-themes" (
          repoEntries "modules/home/qutebrowser/files/themes"
        );
      };
    };
  };
}
