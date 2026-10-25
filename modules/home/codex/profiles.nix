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
  environmentArgs = lib.escapeShellArgs (
    lib.concatLists (
      lib.mapAttrsToList (name: value: [
        "--set"
        name
        value
      ]) environment
    )
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
        mkdir -p "$out/bin" "$out/share/applications" "$out/share/icons"
        cp -rs ${desktopPackage}/share/icons/. "$out/share/icons/"
        ${lib.concatMapStringsSep "\n" (
          name:
          let
            root = "${config.xdg.dataHome}/codex-desktop/profiles/${name}";
            appId = "codex-desktop-${name}";
          in
          ''
            private_bin="$out/libexec/${name}/bin"
            mkdir -p "$private_bin"
            profile_flags=(
              --set CODEX_HOME ${lib.escapeShellArg "${root}/codex"}
              --unset CODEX_SQLITE_HOME
              --set CODEX_CLI_PATH "$private_bin/codex"
              --unset CODEX_LINUX_APP_SERVER_BRIDGE_SOCKET
              --unset CODEX_REMOTE_CONTROL_APP_SERVER_PROXY_SOCKET
              --run ${lib.escapeShellArg "umask 077; mkdir -p -- ${
                lib.escapeShellArgs [
                  "${root}/codex"
                  "${root}/config/Codex-Community"
                ]
              }"}
            )

            # Preserve the selected profile when Desktop starts a CLI with a filtered environment.
            makeWrapper ${resources}/codex "$private_bin/codex" \
              "''${profile_flags[@]}" \
              --prefix PATH : "$out/bin" \
              --suffix PATH : ${lib.makeBinPath [ pkgs.bubblewrap ]} \
              --run ${lib.escapeShellArg ''
                profile_bin="''${CODEX_CLI_PATH%/*}"
                case "''${PATH:-}" in
                  "$profile_bin"|"$profile_bin":*) ;;
                  *) export PATH="$profile_bin''${PATH:+:$PATH}" ;;
                esac
                set -- -c "shell_environment_policy.set.PATH=$PATH" "$@"
              ''}
            ln -s "$private_bin/codex" "$out/bin/codex-${name}"

            # Keep CLI browser helpers on the same runtime as the selected Desktop package.
            makeWrapper ${resources}/cua_node/bin/node_repl "$out/bin/codex-node-repl-${name}" \
              "''${profile_flags[@]}" \
              ${environmentArgs} \
              --set NODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS '1000' \
              --set NODE_REPL_NODE_MODULE_DIRS ${resources}/cua_node/lib/node_modules \
              --set NODE_REPL_NODE_PATH ${resources}/cua_node/bin/node \
              --set NODE_REPL_TRUSTED_CODE_PATHS ${lib.escapeShellArg "${root}/codex:${resources}/cua_node/lib/node_modules:${resources}/plugins/openai-bundled/plugins/browser/scripts"} \
              --set NODE_REPL_TRUSTED_SERVICES ${
                lib.escapeShellArg (
                  builtins.toJSON {
                    browser = "${resources}/plugins/openai-bundled/plugins/browser/scripts/browser-service.mjs";
                  }
                )
              } \
              --set BROWSER_USE_AVAILABLE_BACKENDS 'chrome,iab,mcpapps' \
              --set BROWSER_USE_TINYSKY_ENABLED '1' \
              --set NODE_REPL_INSTRUCTIONS_USE_CASE_BROWSER "" \
              --set NODE_REPL_INSTRUCTIONS_USE_CASE_CHROME "" \
              --set BROWSER_USE_CODEX_APP_BUILD_FLAVOR 'prod' \
              --set BROWSER_USE_CODEX_APP_VERSION ${lib.escapeShellArg desktopPackage.version}

            makeWrapper ${desktopPackage}/bin/codex-desktop "$out/bin/${appId}" \
              "''${profile_flags[@]}" \
              --prefix PATH : "$private_bin" \
              --set NIXOS_OZONE_WL '1' \
              --set CODEX_LINUX_APP_ID ${lib.escapeShellArg appId} \
              --set CODEX_LINUX_APP_DISPLAY_NAME ${lib.escapeShellArg "Codex — ${name}"} \
              --set CODEX_ELECTRON_USER_DATA_PATH ${lib.escapeShellArg "${root}/config/Codex-Community"} \
              --set CHROME_DESKTOP ${lib.escapeShellArg "${desktopId name}.desktop"} \
              --set BAMF_DESKTOP_FILE_HINT "$out/share/applications/${desktopId name}.desktop" \
              ${environmentArgs} \
              --append-flags ${
                lib.escapeShellArg (
                  lib.escapeShellArgs [
                    "--user-data-dir=${root}/config/Codex-Community"
                    "--password-store=basic"
                  ]
                )
              }

            cp ${desktopItem name}/share/applications/*.desktop "$out/share/applications/"
            substituteInPlace "$out/share/applications/${desktopId name}.desktop" \
              --replace-fail 'Exec=${appId}' "Exec=$out/bin/${appId}"
          ''
        ) names}
        ln -s codex-desktop-spreadzhao "$out/bin/codex-desktop"

        export CODEX_HOME="$TMPDIR/completion-home"
        mkdir -p "$CODEX_HOME"
        ${resources}/codex completion zsh > "$TMPDIR/_codex"
        substituteInPlace "$TMPDIR/_codex" \
          --replace-fail '#compdef codex' '#compdef codex-spreadzhao codex-supazodiac' \
          --replace-fail 'compdef _codex codex' 'compdef _codex codex-spreadzhao codex-supazodiac'
        installShellCompletion --zsh "$TMPDIR/_codex"
      '';
in
{
  inherit package;
  desktopFiles = lib.genAttrs (map (name: "applications/${desktopId name}.desktop") names) (path: {
    source = "${package}/share/${path}";
    force = true;
  });
}
