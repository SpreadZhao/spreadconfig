{
  config,
  inputs,
  osConfig,
  pkgs,
  ...
}:

let
  claudeCodePackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
in
{
  home.packages = [ claudeCodePackage ];

  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.templates."claude-settings.json".path;
    # Enforce the SOPS-managed settings file.
    force = true;
  };
}
