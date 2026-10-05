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
  browserDesktop = pkgs.symlinkJoin {
    name = "${desktopBase.name}-browser-proxy";
    paths = [ desktopBase ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/codex-desktop"
      makeWrapper "${desktopBase}/bin/codex-desktop" "$out/bin/codex-desktop" \
        --set CODEX_NODE_REPL_PATH "${browserNodeRepl}"

      # Rewrite every Exec, including the New Window action, to the wrapper.
      desktopFile="$out/share/applications/codex-desktop.desktop"
      rm "$desktopFile"
      substitute "${desktopBase}/share/applications/codex-desktop.desktop" "$desktopFile" \
        --replace-fail "${desktopBase}/bin/codex-desktop" "$out/bin/codex-desktop" \
        --replace-fail "${desktopBase}/share/applications/codex-desktop.desktop" "$desktopFile"
    '';
    inherit (desktopBase) meta passthru;
  };
in

{
  programs.codexDesktopLinux = {
    enable = true;
    package = lib.mkIf hasProxy browserDesktop;
    linuxFeatures = [
      "frameless-titlebar"
      "remote-control-ui"
      "remote-mobile-control"
      "shared-app-server-socket"
    ];
  };

  # Adopt the files used by the initial local repair, so they cannot shadow
  # later declarative proxy or package changes after a Home Manager switch.
  home.file.".local/libexec/codex-browser-node-repl" = lib.mkIf hasProxy {
    source = browserNodeRepl;
    force = true;
  };
  xdg.dataFile."applications/codex-desktop.desktop" = lib.mkIf hasProxy {
    source = "${browserDesktop}/share/applications/codex-desktop.desktop";
    force = true;
  };

  xdg.configFile."codex-desktop/electron-flags.conf" = {
    force = true;
    text = ''
      # Managed by Home Manager.
      --password-store=basic
    '';
  };

  dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;
}
