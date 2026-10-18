{ config, osConfig, ... }:

{
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    gitCredentialHelper.enable = true;
  };

  xdg.configFile = {
    # Replace existing files with the managed GitHub CLI configuration.
    "gh/config.yml".force = true;
    "gh/hosts.yml" = {
      force = true;
      # Link runtime credentials without copying secrets into the Nix store.
      source = config.lib.file.mkOutOfStoreSymlink (osConfig.sops.templates."gh-hosts.yml".path);
    };
  };
}
