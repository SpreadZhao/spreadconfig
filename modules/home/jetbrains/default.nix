{
  config,
  inputs,
  lib,
  pkgs,
  repoLink,
  ...
}:

let
  sdk = import ./sdk.nix { inherit pkgs config; };
  mkJetBrainsIde =
    if inputs.personal-packages ? lib.mkJetBrainsIde then
      inputs.personal-packages.lib.mkJetBrainsIde
    else
      throw "Publish the nix-packages JetBrains helper and update personal-packages, or validate with --override-input personal-packages path:/home/spreadzhao/workspaces/nix-packages.";
  definitions = [
    {
      id = "android-studio";
      package = pkgs.android-studio.withSdk sdk.package;
      propertiesEnv = "STUDIO_PROPERTIES";
      environment = {
        ANDROID_HOME = sdk.path;
        ANDROID_SDK_ROOT = sdk.path;
        JAVA_HOME = pkgs.jdk21.home;
      };
      runtimePackages = [ pkgs.jdk21 ];
      extraProperties."disable.android.first.run" = "true";
    }
    {
      id = "intellij-idea";
      package = pkgs.intellij-idea;
      propertiesEnv = "IDEA_PROPERTIES";
      environment.JAVA_HOME = pkgs.jdk21.home;
      runtimePackages = [ pkgs.jdk21 ];
    }
    {
      id = "clion";
      package = pkgs.clion;
      propertiesEnv = "CLION_PROPERTIES";
      runtimePackages = [
        pkgs.stdenv.cc
        pkgs.cmake
        pkgs.ninja
        pkgs.gdb
      ];
    }
  ];
  ides = map (
    ide:
    ide
    // {
      configDirectory = "${config.xdg.configHome}/jetbrains/${ide.id}/${lib.versions.majorMinor ide.package.version}";
      cacheDirectory = "${config.xdg.cacheHome}/jetbrains/${ide.id}/${lib.versions.majorMinor ide.package.version}";
    }
  ) definitions;
  settings = import ./settings.nix {
    sdkPath = sdk.path;
    inherit
      config
      lib
      pkgs
      ides
      ;
  };
  packages = map (
    ide:
    mkJetBrainsIde {
      inherit pkgs;
      inherit (ide) package propertiesEnv;
      # IdeaVimExtension detects Fcitx through QT_IM_MODULE, not XMODIFIERS.
      environment = {
        QT_IM_MODULE = "fcitx";
      }
      // (ide.environment or { });
      runtimePackages = [
        pkgs.fcitx5
        pkgs.systemd
      ]
      ++ ide.runtimePackages;
      plugins = import ./plugins.nix {
        inherit pkgs;
        inherit (ide) package;
        inherit (inputs.nix-jetbrains-plugins.lib) pluginsForIde;
      };
      extraProperties = {
        "idea.config.path" = ide.configDirectory;
        "idea.system.path" = ide.cacheDirectory;
        "idea.log.path" = "${ide.cacheDirectory}/log";
      }
      // (ide.extraProperties or { });
    }
  ) ides;
in
{
  home.packages = packages;
  home.file = {
    "${sdk.path}".source = "${sdk.package}/libexec/android-sdk";
    ".ideavimrc".source = repoLink "modules/home/jetbrains/files/.ideavimrc";
  };
  home.activation.jetbrainsSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${lib.getExe settings}
  '';
}
