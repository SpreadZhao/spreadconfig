{
  inputs,
  lib,
  pkgs,
  proxy,
  linuxFeatures,
  enableComputerUseUi,
  enableRemoteMobileControl,
}:

let
  proxyVariables = lib.filterAttrs (
    name: _:
    builtins.elem name [
      "http_proxy"
      "https_proxy"
      "all_proxy"
      "no_proxy"
    ]
  ) proxy.envVars;
  hasProxy = lib.any (name: (proxyVariables.${name} or "") != "") [
    "http_proxy"
    "https_proxy"
    "all_proxy"
  ];
  upstream =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop.override
      {
        inherit enableComputerUseUi;
        linuxFeatureIds = linuxFeatures ++ lib.optional enableRemoteMobileControl "remote-mobile-control";
      };
in
{
  inherit hasProxy;

  # The upstream browser-proxy feature reads these from the app-server environment.
  environment = lib.optionalAttrs hasProxy (
    proxyVariables
    // lib.mapAttrs' (name: value: lib.nameValuePair (lib.toUpper name) value) proxyVariables
    // {
      NODE_USE_ENV_PROXY = "1";
      # networking.nix uses Clash's mixed HTTP/SOCKS listener on the same port.
      CODEX_DESKTOP_SOCKS_PROXY_URL = lib.replaceStrings [ "http://" ] [ "socks5h://" ] proxy.default;
    }
  );

  # Browser Use proxy inheritance does not cover Desktop's cloud WebSockets.
  package =
    if !hasProxy then
      upstream
    else
      upstream.overrideAttrs (previous: {
        postInstall = (previous.postInstall or "") + ''
          resources="$out/opt/codex-desktop/resources"
          extracted="$TMPDIR/cloud-websocket-asar"
          asar list --is-pack "$resources/app.asar" > "$TMPDIR/cloud-websocket-layout"
          asar extract "$resources/app.asar" "$extracted"
          cp -a "$resources/app.asar.unpacked/." "$extracted/"
          chmod -R u+w "$extracted"
          python3 ${./patches/cloud-websocket.py} "$extracted/.vite/build"
          node --check "$extracted"/.vite/build/main-*.js

          layout_helper="${inputs.codex-desktop-linux}/scripts/patches/lib/asar-layout.js"
          node "$layout_helper" "$TMPDIR/cloud-websocket-layout" "$extracted" \
            "$TMPDIR/cloud-websocket-ordering" "$TMPDIR/cloud-websocket-unpack"
          unpack_args=()
          unpack_pattern="$(cat "$TMPDIR/cloud-websocket-unpack")"
          if [[ -n "$unpack_pattern" ]]; then
            unpack_args=(--unpack-dir "$unpack_pattern")
          fi
          asar pack "$extracted" "$TMPDIR/cloud-websocket.asar" \
            --ordering "$TMPDIR/cloud-websocket-ordering" \
            --unpack '{*.node,*.so,*.dylib}' "''${unpack_args[@]}"
          asar list --is-pack "$TMPDIR/cloud-websocket.asar" > "$TMPDIR/cloud-websocket-output-layout"
          node "$layout_helper" verify "$TMPDIR/cloud-websocket-layout" "$TMPDIR/cloud-websocket-output-layout"
          mv "$TMPDIR/cloud-websocket.asar" "$resources/app.asar"
        '';
      });
}
