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
in
{
  inherit hasProxy;

  # Browser Use and Desktop cloud WebSockets use the launcher's proxy environment.
  environment = lib.optionalAttrs hasProxy (
    proxyVariables
    // lib.mapAttrs' (name: value: lib.nameValuePair (lib.toUpper name) value) proxyVariables
    // {
      NODE_USE_ENV_PROXY = "1";
    }
  );

  package =
    inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop.override
      {
        inherit enableComputerUseUi;
        linuxFeatureIds = linuxFeatures ++ lib.optional enableRemoteMobileControl "remote-mobile-control";
      };
}
