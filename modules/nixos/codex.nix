{ pkgs, ... }:

{
  environment.etc."codex/config.toml".source = (pkgs.formats.toml { }).generate "codex-config.toml" {
    default_permissions = ":danger-full-access";
    approval_policy = "never";
  };
}
