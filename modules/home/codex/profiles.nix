{
  config,
  lib,
  pkgs,
  desktopPackage,
  environment,
}:

let
  resources = "${desktopPackage}/opt/codex-desktop/resources";
  names = [
    "spreadzhao"
    "supazodiac"
  ];
  environmentFlags = lib.concatLists (
    lib.mapAttrsToList (name: value: [
      "--set"
      name
      value
    ]) environment
  );
  desktopId = name: if name == "spreadzhao" then "codex-desktop" else "codex-desktop-${name}";
  desktopItem =
    name:
    pkgs.makeDesktopItem {
      name = desktopId name;
      desktopName = "Codex — ${name}";
      comment = "Isolated Codex Desktop profile: ${name}";
      exec = "codex-desktop-${name} %u";
      icon = "codex-desktop";
      categories = [ "Development" ];
      mimeTypes = [
        "x-scheme-handler/codex"
        "x-scheme-handler/codex-browser-sidebar"
      ];
      startupWMClass = "codex-desktop-${name}";
    };
  profileDefinitions = map (
    name:
    let
      root = "${config.xdg.dataHome}/codex-desktop/profiles/${name}";
    in
    pkgs.writeText "codex-profile-${name}.sh" (
      lib.toShellVars {
        PROFILE_NAME = name;
        PROFILE_ROOT = root;
        PROFILE_DESKTOP_ID = desktopId name;
        PROFILE_DESKTOP_FILE = "${desktopItem name}/share/applications/${desktopId name}.desktop";
        PROFILE_SETUP = "umask 077; mkdir -p -- ${
          lib.escapeShellArgs [
            "${root}/codex"
            "${root}/config/Codex-Community"
          ]
        }";
        PROFILE_DESKTOP_FLAGS = lib.escapeShellArgs [
          "--user-data-dir=${root}/config/Codex-Community"
          "--password-store=basic"
        ];
        PROFILE_TRUSTED_SERVICES = builtins.toJSON {
          browser = "${resources}/plugins/openai-bundled/plugins/browser/scripts/browser-service.mjs";
        };
      }
    )
  ) names;
  buildSettings = pkgs.writeText "codex-profile-build.sh" (
    lib.toShellVars {
      DESKTOP_PACKAGE = toString desktopPackage;
      DESKTOP_VERSION = desktopPackage.version;
      CODEX_RESOURCES = resources;
      PROFILE_DEFINITIONS = map toString profileDefinitions;
      ENVIRONMENT_FLAGS = environmentFlags;
      BUBBLEWRAP_PATH = lib.makeBinPath [ pkgs.bubblewrap ];
      CLI_ENVIRONMENT_SCRIPT = "${./scripts/runtime/cli-environment.sh}";
    }
  );
  package =
    pkgs.runCommand "codex-desktop-profiles-${desktopPackage.version}"
      {
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.installShellFiles
        ];
        meta = desktopPackage.meta // {
          mainProgram = "codex-desktop";
        };
        passthru.desktopBase = desktopPackage;
      }
      ''
        source ${buildSettings}
        source ${./scripts/build/profiles.sh} "$out"
      '';
in
{
  inherit package;
  desktopFiles = lib.genAttrs (map (name: "applications/${desktopId name}.desktop") names) (path: {
    source = "${package}/share/${path}";
    force = true;
  });
}
