{ config, osConfig, ... }:

{
  # Cover login shells and applications started by the user systemd manager.
  home.sessionVariables.GH_CONFIG_DIR = "${config.xdg.configHome}/gh";
  systemd.user.sessionVariables.GH_CONFIG_DIR = config.home.sessionVariables.GH_CONFIG_DIR;

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
