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
      envVars = lib.mkIf (proxy != "") {
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
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        substituters = [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
        max-jobs = 2;
        cores = 4;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      daemonIOSchedClass = lib.mkDefault "idle";
      daemonCPUSchedPolicy = lib.mkDefault "idle";
    };
}
