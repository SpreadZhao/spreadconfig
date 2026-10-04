{
  config,
  inputs,
  osConfig,
  pkgs,
  ...
}:

let
  claudeCodePackage = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ claudeCodePackage ];

  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.sops.templates."claude-settings.json".path;
    # Replace the writable file from the previous GLM configuration.
    force = true;
  };
}
