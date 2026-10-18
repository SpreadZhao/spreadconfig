{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  programs.gh = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "gh-configured-${pkgs.gh.version}";
      paths = [ pkgs.gh ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # Codex profiles override XDG_CONFIG_HOME. Default to the managed login
      # while allowing a nonempty GH_CONFIG_DIR override.
      postBuild = ''
        wrapProgram "$out/bin/gh" \
          --set-default GH_CONFIG_DIR ${lib.escapeShellArg "${config.xdg.configHome}/gh"}
      '';
      meta = pkgs.gh.meta;
    };
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
