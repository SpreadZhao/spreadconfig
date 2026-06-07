{
  lib,
  pkgs,
  ...
}:

{
  # User-global skills exposed at ~/.agents/skills.
  #
  # Example:
  # user.my-skill = ./local/my-skill;
  #
  # Example with an external pinned source:
  # user.some-github-skill = "${pkgs.fetchFromGitHub {
  #   owner = "owner";
  #   repo = "repo";
  #   rev = "v1.0.0";
  #   hash = "sha256-...";
  # }}/skills/some-github-skill";
  user = { };

  # Codex-home skills exposed at ~/.codex/skills. Prefer user above for normal
  # personal skills; keep this for compatibility with installers or experiments
  # that explicitly expect CODEX_HOME/skills.
  codex = { };

  # Machine-wide skills exposed at /etc/codex/skills.
  system = { };
}
