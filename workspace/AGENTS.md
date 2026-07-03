# Workspace Agent Surface

This directory is a cross-repository agent workspace, not a monorepo.

## Repositories

- `spreadconfig`: NixOS, Home Manager, local skill sources, machine tooling,
  including the LeetCode coach workflow skill.
- `SecondBrain`: notes, diary entries, learning summaries, article archives.
- `SpreadStudy`: programming practice, LeetCode solutions, language study code.
- `ai-teacher`: legacy experiments for coaching and review workflows.
- `codex-ecc`: large external skill and harness research surface.
- `rime-android-remote`: Android and input-method experiments.

## Dynamic Skills

Use `agent-skills` before starting a domain-specific agent session from this
directory:

```bash
agent-skills list
agent-skills use leetcode
agent-skills add frontend
agent-skills refresh
agent-skills status
```

Profiles can be combined. `agent-skills use leetcode notes` replaces the active
managed set with the union of those profiles. `agent-skills add frontend` keeps
the current set and adds another profile. Switching profiles only changes
symlinks managed by `agent-skills`.

Editing local skill content usually takes effect immediately because active
workspace skills are symlinks to their sources. After changing profile
membership in `spreadconfig/skills/sources.nix`, switch Home Manager first so
the manifest is regenerated, then run `agent-skills refresh` to reapply the
currently active profiles.

Global home skills remain managed by Nix under `~/.agents/skills`,
`~/.claude/skills`, or `~/.codex/skills`. Workspace profiles are for
cross-repository sessions started from `~/workspaces`.

Each skill declares where it should appear. A skill with target `agents` is
linked under `./.agents/skills`, `claude` under `./.claude/skills`, and `codex`
under `./.codex/skills`.

Workspace runtime state is not managed by Nix or Home Manager. For LeetCode
work, runtime state lives under `./SpreadStudy/Leetcode/.leetcode-coach`.

Common profiles:

- `leetcode`: review code in `SpreadStudy`, use the `leetcode-coach` skill, and
  write notes to `SecondBrain`.
- `notes`: note ingestion, Obsidian, diary, and WeChat workflows.
- `nixos`: system configuration and hardware/debug workflows.
- `android`: Android development and Waydroid/device control.
- `frontend`: frontend/UI generation and review workflows.

## LeetCode Study Flow

1. Work from `SpreadStudy` for source code, tests, and submitted solutions.
2. Use the `leetcode-coach` skill for review, hints, and teaching-oriented
   feedback.
3. Write durable summaries, mistakes, and patterns into `SecondBrain`.
4. Keep system/tooling changes in `spreadconfig`.
