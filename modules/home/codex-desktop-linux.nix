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
  # Configure user XDG directories through shell_environment_policy.
  # The gh wrapper sets its default configuration directory independently.
  shellEnvironmentArgs = lib.escapeShellArgs (
    lib.concatLists (
      lib.mapAttrsToList
        (name: value: [
          "-c"
          "shell_environment_policy.set.${name}=${builtins.toJSON value}"
        ])
        {
          XDG_CONFIG_HOME = config.xdg.configHome;
          XDG_DATA_HOME = config.xdg.dataHome;
          XDG_CACHE_HOME = config.xdg.cacheHome;
          XDG_STATE_HOME = config.xdg.stateHome;
        }
    )
  );

  # Desktop regenerates node_repl and cua_repl configuration on startup and
  # filters proxy variables from their environment. Set them at the final
  # executable boundary instead of editing the generated config.toml/.mcp.json.
  browserNodeRepl = pkgs.writeShellScript "codex-browser-node-repl" ''
    set -euo pipefail
    : "''${NODE_REPL_NODE_PATH:?Codex did not provide its bundled Node path}"
    # Artifact Session supplies its own Node binary under the profile cache;
    # node_repl itself remains in Desktop's bundled cua_node directory.
    runtime_executable="${desktopBase}/opt/codex-desktop/resources/cua_node/bin/node_repl"
    if [[ ! -x "$runtime_executable" || "$runtime_executable" -ef "$0" ]]; then
      echo "Cannot locate the original Codex node_repl executable" >&2
      exit 1
    fi
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "export ${name}=${lib.escapeShellArg value}") browserEnvironment
    )}
    exec "$runtime_executable" "$@"
  '';

  desktopUpstream =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop.override
      {
        enableComputerUseUi = cfg.computerUseUi.enable;
        linuxFeatureIds =
          cfg.linuxFeatures ++ lib.optional cfg.remoteMobileControl.enable "remote-mobile-control";
      };
  desktopProfileCompatibility = builtins.toFile "desktop-profile-compat.py" ''
    """Minimal Linux bundle fixes until upstream honors XDG cache and WS proxy."""
    import pathlib
    import re
    import sys

    build = pathlib.Path(sys.argv[1])
    identifier = r"[A-Za-z_$][\w$]*(?:\.default)?"
    cache_call = re.compile(
        rf"(?P<path>{identifier})\.join\("
        rf"(?P<os>{identifier})\.homedir\(\),`\.cache`,`codex-runtimes`"
    )

    def cache_replacement(match):
        path, os_module = match.group("path", "os")
        return (
            f"{path}.join(process.env.XDG_CACHE_HOME||"
            f"{path}.join({os_module}.homedir(),`.cache`),`codex-runtimes`"
        )

    for pattern, expected in (
        ("application-network-startup-*.js", 3),
        ("main-*.js", 2),
        ("worker.js", 1),
    ):
        matches = list(build.glob(pattern))
        if len(matches) != 1:
            raise SystemExit(f"Expected one bundle matching {pattern}: {matches}")
        file = matches[0]
        source, count = cache_call.subn(cache_replacement, file.read_text())
        if count != expected:
            raise SystemExit(f"{file.name}: expected {expected} cache paths, found {count}")
        if pattern == "main-*.js":
            # Keep the localhost bypass and the internal development proxy.
            proxy_route = re.compile(
                r"(?P<host>[A-Za-z_$][\w$]*)\.endsWith\(`\.internal\.api\.openai\.org`\)"
                r"\?(?P<proxy>[A-Za-z_$][\w$]*):void 0"
            )
            source, count = proxy_route.subn(
                r"\g<host>.endsWith(`.internal.api.openai.org`)?\g<proxy>:"
                r"process.env.CODEX_DESKTOP_SOCKS_PROXY_URL",
                source,
            )
            if count != 1:
                raise SystemExit(f"Expected one external WebSocket proxy route, found {count}")
        file.write_text(source)
  '';
  # The GUI hardcodes ~/.cache while its CLI validates XDG_CACHE_HOME. Reuse
  # upstream's ASAR layout helper so native modules keep their unpacked layout.
  desktopBase = desktopUpstream.overrideAttrs (previous: {
    postInstall = (previous.postInstall or "") + ''
      resources="$out/opt/codex-desktop/resources"
      extracted="$TMPDIR/profile-compat-asar"
      asar list --is-pack "$resources/app.asar" > "$TMPDIR/profile-compat-layout"
      asar extract "$resources/app.asar" "$extracted"
      cp -a "$resources/app.asar.unpacked/." "$extracted/"
      chmod -R u+w "$extracted"
      python3 ${desktopProfileCompatibility} "$extracted/.vite/build"
      for bundle in "$extracted"/.vite/build/{application-network-startup-*,main-*,worker}.js; do
        node --check "$bundle"
      done
      layout_helper="${inputs.codex-desktop-linux}/scripts/patches/lib/asar-layout.js"
      node "$layout_helper" "$TMPDIR/profile-compat-layout" "$extracted" \
        "$TMPDIR/profile-compat-ordering" "$TMPDIR/profile-compat-unpack"
      asar pack "$extracted" "$TMPDIR/profile-compatible.asar" \
        --ordering "$TMPDIR/profile-compat-ordering" \
        --unpack '{*.node,*.so,*.dylib}' \
        --unpack-dir "$(cat "$TMPDIR/profile-compat-unpack")"
      asar list --is-pack "$TMPDIR/profile-compatible.asar" > "$TMPDIR/profile-compat-output-layout"
      node "$layout_helper" verify "$TMPDIR/profile-compat-layout" "$TMPDIR/profile-compat-output-layout"
      mv "$TMPDIR/profile-compatible.asar" "$resources/app.asar"
    '';
  });
  # networking.nix uses Clash's mixed HTTP/SOCKS listener on the same port.
  desktopSocksProxy =
    lib.replaceStrings [ "http://" ] [ "socks5h://" ]
      osConfig.networking.proxy.default;
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
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.installShellFiles
        ];
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
              if [[ "$relative" == features/* ]]; then
                # The REPL sandbox filters private launcher variables. Keep
                # the CODEX_HOME guard and locate this package without them.
                substituteInPlace "$target" \
                  --replace-fail 'CODEX_LINUX_APP_DIR:?CODEX_LINUX_APP_DIR is required' \
                  "CODEX_LINUX_APP_DIR:=$profile_package/opt/codex-desktop" \
                  --replace-fail 'exec "$real_codex"' \
                  ${lib.escapeShellArg "exec \"$real_codex\" ${shellEnvironmentArgs}"}
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

            # Use upstream's Wayland opt-in, including its native IME flags.
            makeWrapper "$launcher" "$out/bin/${appId}" \
              "''${profile_flags[@]}" \
              --set NIXOS_OZONE_WL '1' \
              --set CODEX_LINUX_APP_ID '${appId}' \
              --set CODEX_LINUX_APP_DISPLAY_NAME 'Codex — ${name}' \
              --set CODEX_ELECTRON_USER_DATA_PATH '${root}/config/Codex-Community' \
              --set CHROME_DESKTOP '${if name == "spreadzhao" then "codex-desktop" else appId}.desktop' \
              --set BAMF_DESKTOP_FILE_HINT "$out/share/applications/${
                if name == "spreadzhao" then "codex-desktop" else appId
              }.desktop" \
              ${lib.optionalString hasProxy "--set CODEX_DESKTOP_SOCKS_PROXY_URL '${desktopSocksProxy}'"} \
              ${lib.optionalString hasProxy "--set CODEX_NODE_REPL_PATH '${browserNodeRepl}'"} \
              --append-flags '--password-store=basic'

            cli_wrapper="$profile_package/opt/codex-desktop/.codex-linux/features/community-profile-isolation/codex-cli-wrapper.sh"
            makeWrapper "$cli_wrapper" "$out/bin/codex-${name}" \
              "''${profile_flags[@]}" \
              --set CODEX_LINUX_APP_DIR "$profile_package/opt/codex-desktop" \
              --set CODEX_CLI_PATH "$cli_wrapper"

            cp ${desktopItem name}/share/applications/*.desktop "$out/share/applications/"
            substituteInPlace "$out/share/applications/${
              if name == "spreadzhao" then "codex-desktop" else appId
            }.desktop" \
              --replace-fail 'Exec=${appId}' "Exec=$out/bin/${appId}"
          ''
        ) profileNames}
        ln -s codex-desktop-spreadzhao "$out/bin/codex-desktop"

        # Reuse the bundled CLI's completion for both explicit profile names.
        export CODEX_HOME="$TMPDIR/completion-home"
        mkdir -p "$CODEX_HOME"
        ${desktopBase}/opt/codex-desktop/resources/codex completion zsh > "$TMPDIR/_codex"
        substituteInPlace "$TMPDIR/_codex" \
          --replace-fail '#compdef codex' '#compdef codex-spreadzhao codex-supazodiac' \
          --replace-fail 'compdef _codex codex' 'compdef _codex codex-spreadzhao codex-supazodiac'
        installShellCompletion --zsh "$TMPDIR/_codex"
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

  # Replace local launcher files so declarative proxy and package updates apply.
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

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "x-scheme-handler/codex"
    "x-scheme-handler/codex-browser-sidebar"
  ] (_: "codex-desktop.desktop");
}
