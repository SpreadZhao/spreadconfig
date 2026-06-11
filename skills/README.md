# Skill Registry

This directory is the declarative source registry for Codex skills.

- Put local skill sources under `skills/local/<name>/`.
- Register user-global skills in `skills/sources.nix` under `user`.
- Register compatibility skills for `~/.codex/skills` under `codex`.
- Register machine-wide skills in `skills/sources.nix` under `system`.

Local skill snapshots live in `skills/local/<name>/` when there is no pinned
external source or the currently installed version should be preserved exactly.
Prefer flake inputs or fixed-output fetchers for skills with a clear upstream so
the skill source does not need to be vendored into this repository.
