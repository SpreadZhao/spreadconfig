{
  config,
  inputs,
  osConfig,
  pkgs,
  ...
}:

{
  home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];

  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.templates."claude-settings.json".path;
    # Enforce the SOPS-managed settings file.
    force = true;
  };
}
