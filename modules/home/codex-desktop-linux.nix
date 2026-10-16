{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  cfg = config.programs.codexDesktopLinux;
  proxyVariables = lib.filterAttrs (
    name: _:
    builtins.elem name [
      "http_proxy"
      "https_proxy"
      "all_proxy"
      "no_proxy"
    ]
  ) osConfig.networking.proxy.envVars;
  hasProxy = lib.any (name: (proxyVariables.${name} or "") != "") [
    "http_proxy"
    "https_proxy"
    "all_proxy"
  ];
  browserEnvironment =
    proxyVariables
    // lib.mapAttrs' (name: value: lib.nameValuePair (lib.toUpper name) value) proxyVariables
    // {
      NODE_USE_ENV_PROXY = "1";
    };

  # Desktop regenerates node_repl and cua_repl configuration on startup and
  # filters proxy variables from their environment. Set them at the final
  # executable boundary instead of editing the generated config.toml/.mcp.json.
  browserNodeRepl = pkgs.writeShellScript "codex-browser-node-repl" ''
    set -euo pipefail
    : "''${NODE_REPL_NODE_PATH:?Codex did not provide its bundled Node path}"
    runtime_bin="''${NODE_REPL_NODE_PATH%/*}"
    runtime_executable="$runtime_bin/node_repl"
    if [[ ! -x "$runtime_executable" || "$runtime_executable" -ef "$0" ]]; then
      echo "Cannot locate the original Codex node_repl executable" >&2
      exit 1
    fi
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") browserEnvironment
    )}
    exec "$runtime_executable" "$@"
  '';

  desktopBase =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop.override
      {
        enableComputerUseUi = cfg.computerUseUi.enable;
        linuxFeatureIds =
          cfg.linuxFeatures ++ lib.optional cfg.remoteMobileControl.enable "remote-mobile-control";
      };
  profileNames = [
    "spreadzhao"
    "supazodiac"
  ];
  profileRoot = name: "${config.xdg.dataHome}/codex-desktop/profiles/${name}";
  desktopItem =
    name:
    pkgs.makeDesktopItem {
      name = if name == "spreadzhao" then "codex-desktop" else "codex-desktop-${name}";
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

  # Keep upstream's isolation hooks and CLI checks. Only their canonical paths
  # differ between profiles; the signed runtime/resources remain shared links.
  desktopProfiles =
    pkgs.runCommand "codex-desktop-profiles-${desktopBase.version}"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta = desktopBase.meta // {
          mainProgram = "codex-desktop";
        };
        passthru = { inherit desktopBase; };
      }
      ''
        mkdir -p "$out/bin" "$out/share/applications" "$out/share/icons"
        cp -rs ${desktopBase}/share/icons/. "$out/share/icons/"
        ${lib.concatMapStringsSep "\n" (
          name:
          let
            root = profileRoot name;
            appId = "codex-desktop-${name}";
          in
          ''
            profile_package="$out/libexec/${name}"
            mkdir -p "$profile_package"
            cp -rs ${desktopBase}/. "$profile_package/"
            find "$profile_package" -type d -exec chmod u+w {} +
            launcher="$profile_package/bin/codex-desktop"
            rm "$launcher"
            substitute ${desktopBase}/bin/codex-desktop "$launcher" \
              --replace-fail '${desktopBase}/' "$profile_package/"
            chmod +x "$launcher"

            for relative in \
              env.d/community-profile-isolation-community-profile-isolation.env \
              launcher.d/community-profile-isolation-community-profile-isolation.sh \
              features/community-profile-isolation/codex-cli-wrapper.sh; do
              target="$profile_package/opt/codex-desktop/.codex-linux/$relative"
              original="$(readlink -f "$target")"
              rm "$target"
              if [[ "$relative" == launcher.d/* ]]; then
                substitute "$original" "$target" \
                  --replace-fail '$HOME/.config/Codex-Community' '${root}/config/Codex-Community'
              else
                substitute "$original" "$target" \
                  --replace-fail '$HOME/.codex-community' '${root}/codex'
              fi
              chmod --reference="$original" "$target"
            done

            profile_flags=(
              --set CODEX_HOME '${root}/codex'
              --set CODEX_SQLITE_HOME '${root}/codex'
              --set XDG_CONFIG_HOME '${root}/config'
              --set XDG_DATA_HOME '${root}/data'
              --set XDG_STATE_HOME '${root}/state'
              --set XDG_CACHE_HOME '${root}/cache'
              --unset CODEX_LINUX_APP_SERVER_BRIDGE_SOCKET
              --unset CODEX_REMOTE_CONTROL_APP_SERVER_PROXY_SOCKET
              --run ${lib.escapeShellArg "umask 077; mkdir -p -- ${
                lib.escapeShellArgs (
                  map (dir: "${root}/${dir}") [
                    "codex"
                    "config"
                    "data"
                    "state"
                    "cache"
                  ]
                )
              }"}
            )

            makeWrapper "$launcher" "$out/bin/${appId}" \
              "''${profile_flags[@]}" \
              --set CODEX_LINUX_APP_ID '${appId}' \
              --set CODEX_LINUX_APP_DISPLAY_NAME 'Codex — ${name}' \
              --set CODEX_ELECTRON_USER_DATA_PATH '${root}/config/Codex-Community' \
              --set CHROME_DESKTOP '${if name == "spreadzhao" then "codex-desktop" else appId}.desktop' \
              --set BAMF_DESKTOP_FILE_HINT "$out/share/applications/${
                if name == "spreadzhao" then "codex-desktop" else appId
              }.desktop" \
              ${lib.optionalString hasProxy "--set CODEX_NODE_REPL_PATH '${browserNodeRepl}'"} \
              --append-flags '--password-store=basic'

            cp ${desktopItem name}/share/applications/*.desktop "$out/share/applications/"
            substituteInPlace "$out/share/applications/${
              if name == "spreadzhao" then "codex-desktop" else appId
            }.desktop" \
              --replace-fail 'Exec=${appId}' "Exec=$out/bin/${appId}"
          ''
        ) profileNames}
        ln -s codex-desktop-spreadzhao "$out/bin/codex-desktop"

      '';
in

{
  programs.codexDesktopLinux = {
    enable = true;
    package = desktopProfiles;
    linuxFeatures = [
      "frameless-titlebar"
      "remote-control-ui"
      "remote-mobile-control"
      "community-profile-isolation"
    ];
  };

  # Adopt the files used by the initial local repair, so they cannot shadow
  # later declarative proxy or package changes after a Home Manager switch.
  home.file.".local/libexec/codex-browser-node-repl" = lib.mkIf hasProxy {
    source = browserNodeRepl;
    force = true;
  };
  xdg.dataFile =
    lib.genAttrs
      (map (
        name:
        "applications/${if name == "spreadzhao" then "codex-desktop" else "codex-desktop-${name}"}.desktop"
      ) profileNames)
      (path: {
        source = "${desktopProfiles}/share/${path}";
        force = true;
      })
    // lib.listToAttrs (
      lib.concatMap (
        name:
        map
          (desktopName: {
            name = "codex-desktop/profiles/${name}/data/applications/${desktopName}";
            value = {
              source = "${desktopProfiles}/share/applications/codex-desktop.desktop";
              force = true;
            };
          })
          [
            "codex-desktop.desktop"
            "chatgpt.desktop"
          ]
      ) profileNames
    )
    //
      lib.genAttrs
        (map (name: "codex-desktop/profiles/${name}/data/applications/mimeapps.list") profileNames)
        (_: {
          source = config.xdg.configFile."mimeapps.list".source;
          force = true;
        });

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
}
