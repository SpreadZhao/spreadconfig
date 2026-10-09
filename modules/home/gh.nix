{ config, osConfig, ... }:

{
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    gitCredentialHelper.enable = true;
  };

  xdg.configFile = {
    # Adopt files previously written by gh and the old activation script.
    "gh/config.yml".force = true;
    "gh/hosts.yml" = {
      force = true;
      # Link runtime credentials without copying secrets into the Nix store.
      source = config.lib.file.mkOutOfStoreSymlink (osConfig.sops.templates."gh-hosts.yml".path);
    };
  };
}
