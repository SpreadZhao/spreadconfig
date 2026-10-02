{ config, osConfig, ... }:

{
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    gitCredentialHelper.enable = true;
  };

  # Link the runtime-rendered file without copying secrets into the Nix store.
  xdg.configFile."gh/hosts.yml".source = config.lib.file.mkOutOfStoreSymlink (
    osConfig.sops.templates."gh-hosts.yml".path
  );
}
