# Skill Registry

This directory is the declarative source registry for Codex skills.

- Put local skill sources under `skills/local/<name>/`.
- Register user-global skills in `skills/sources.nix` under `user`.
- Register compatibility skills for `~/.codex/skills` under `codex`.
- Register machine-wide skills in `skills/sources.nix` under `system`.

No actual skills are registered by default. Add entries to `sources.nix` when a
skill should be installed declaratively.
