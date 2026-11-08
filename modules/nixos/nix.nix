{
  config,
  lib,
  inputs,
  ...
}:

{
  nix =
    let
      flakeInputs = lib.filterAttrs (name: input: name != "self" && lib.isType "flake" input) inputs;
      proxy = config.networking.proxy.default or "";
      noProxy = config.networking.proxy.noProxy or "";
    in
    {
      envVars = {
        GOPROXY = "https://goproxy.cn,https://proxy.golang.org,direct";
        GOSUMDB = "sum.golang.org";
      }
      // lib.optionalAttrs (proxy != null && proxy != "") {
        all_proxy = proxy;
        ftp_proxy = proxy;
        http_proxy = proxy;
        https_proxy = proxy;
        rsync_proxy = proxy;
        no_proxy = noProxy;

        ALL_PROXY = proxy;
        FTP_PROXY = proxy;
        HTTP_PROXY = proxy;
        HTTPS_PROXY = proxy;
        RSYNC_PROXY = proxy;
        NO_PROXY = noProxy;

        npm_config_proxy = proxy;
        npm_config_https_proxy = proxy;
        npm_config_noproxy = noProxy;
        NPM_CONFIG_PROXY = proxy;
        NPM_CONFIG_HTTPS_PROXY = proxy;
        NPM_CONFIG_NOPROXY = noProxy;
      };

      settings = {
        min-free = 0;
        # Enable flakes and the nix CLI.
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Disable the global registry.
        flake-registry = "";
        # Keep the search path aligned with the flake registry.
        nix-path = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
        # Try the NixOS mirrors and cache before Numtide.
        substituters = lib.mkForce [
          "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=20"
          "https://cache.nixos.org?priority=40"
          "https://cache.numtide.com?priority=50"
        ];
        trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
        download-attempts = 3;
        connect-timeout = 10;
        stalled-download-timeout = 90;
        http-connections = 10;
        max-jobs = 2;
        cores = 4;
      };
      # Disable channels.
      channel.enable = false;
      gc.automatic = false;

      # Match the registry to the locked flake inputs.
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;

      daemonIOSchedClass = lib.mkDefault "idle";
      daemonCPUSchedPolicy = lib.mkDefault "idle";
    };

  environment.variables.NIX_REMOTE = "daemon";
  systemd.services.nix-daemon.serviceConfig.Slice = "-.slice";
}
