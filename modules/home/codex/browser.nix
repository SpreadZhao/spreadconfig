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
          source ${./scripts/build/patch-cloud-websocket.sh} "$out" \
            ${./patches/cloud-websocket.py} \
            ${inputs.codex-desktop-linux}/scripts/patches/lib/asar-layout.js
        '';
      });
}
