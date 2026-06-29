---
name: spreadconfig-skill-authoring
description: Create or update Nix-managed skills in the spreadconfig repository. Use when the user asks to add, modify, register, expose, profile, or switch a skill that lives under spreadconfig/skills/local or is installed through skills/sources.nix, especially when they mention NixOS, Home Manager, agent-skills, workspace profiles, or avoiding direct edits to installed skill symlinks.
---

# Spreadconfig Skill Authoring

## Overview

Use this skill to author skills whose source of truth is the `spreadconfig` repository. Pair it with `$skill-creator` for general skill design quality; this skill covers the spreadconfig-specific Nix, Home Manager, and `agent-skills` wiring.

## Source of Truth

Edit declarative sources, not installed copies:

- Local skill content lives in `/home/spreadzhao/workspaces/spreadconfig/skills/local/<skill-name>/`.
- Skill registration and exposure live in `/home/spreadzhao/workspaces/spreadconfig/skills/sources.nix`.
- Home-global installs are produced from `globalSkills`.
- Workspace profile installs are produced from `workspaceProfiles` and linked by `agent-skills`.

Do not directly edit installed skill locations such as `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/workspaces/.agents/skills`, `~/workspaces/.claude/skills`, or `~/workspaces/.codex/skills`. If a symlink points somewhere unexpected, inspect it and fix the declarative source or profile entry instead.

## Workflow Decision

- New local skill: create `skills/local/<skill-name>/`, then register it in `skills/sources.nix`.
- Existing local skill content change: edit `skills/local/<skill-name>/`; no switch is needed if the existing installed path is already a symlink to this source.
- Profile or global exposure change: edit `skills/sources.nix`; tell the user a Home Manager switch is required before relying on regenerated manifests or global symlinks.
- External/upstream skill: prefer adding or reusing a flake input plus a `skills/sources.nix` source entry instead of vendoring files, unless the user explicitly wants a local fork.
- Workspace activation: after a switch updates the manifest, use `agent-skills use <profile>`, `agent-skills add <profile>`, or `agent-skills status` from `/home/spreadzhao/workspaces`.

## Creating a Local Skill

1. Choose a lowercase hyphen-case name, 64 characters or fewer.
2. When available, run the `$skill-creator` initializer from the spreadconfig tree:

```bash
nix shell nixpkgs#python3 --command python3 /home/spreadzhao/.codex/skills/.system/skill-creator/scripts/init_skill.py <skill-name> --path /home/spreadzhao/workspaces/spreadconfig/skills/local
```

3. Replace the generated `SKILL.md` TODOs with concise, task-focused instructions.
4. Keep `agents/openai.yaml` aligned with the skill name and trigger. Its `interface.default_prompt` should explicitly mention `$<skill-name>`.
5. Create `scripts/`, `references/`, or `assets/` only when the skill actually needs progressive-disclosure resources.
6. Register the skill in `skills/sources.nix` using the local source helper:

```nix
mySkill = {
  my-skill = {
    source = localSkillSource "my-skill";
    targets = agentTargets;
  };
};
```

7. Add the new set to `skillSets = { inherit ...; };`.
8. Add it to the appropriate `workspaceProfiles.<profile>` list for dynamic workspace usage, or to `globalSkills` only when it should always be available from the user's home skill directories.

Use `agentTargets` for the common `agents` plus `claude` install shape. Use an explicit target list such as `[ "agents" ]` or `[ "codex" ]` only when the skill is intentionally scoped to one surface.

## Updating an Existing Skill

1. Inspect `skills/sources.nix` to find the skill set, target list, and profile/global exposure.
2. Edit the source under `skills/local/<skill-name>/` when it is a local skill.
3. Update frontmatter `description` when trigger conditions change.
4. Update `agents/openai.yaml` when the display name, short description, default prompt, or invocation behavior changes.
5. If renaming or moving a skill, update the skill directory, `SKILL.md` frontmatter `name`, `agents/openai.yaml`, `skills/sources.nix`, and any affected profile entries together.

## Applying Changes

- Content-only edits to an already linked local skill usually take effect immediately because Home Manager links to the working tree source.
- Changes to `globalSkills` require a Home Manager switch to create or update home-level symlinks.
- Changes to `workspaceProfiles` require a Home Manager switch to regenerate `~/.config/spreadconfig/agent-skill-profiles.tsv`; after that, run `agent-skills use` or `agent-skills add` for the desired workspace profile.
- Do not run Home Manager, NixOS, `sns_until switch`, or any equivalent switch command for this skill. Report that a switch is required and leave the actual switch to the user.
- When useful, mention the host-specific spreadconfig switch script chosen by `$spreadconfig-nix`, but present it as the command for the user to run.

## Validation

Run the skill validator after creating or materially changing a skill:

```bash
nix shell nixpkgs#python3 --command python3 /home/spreadzhao/.codex/skills/.system/skill-creator/scripts/quick_validate.py /home/spreadzhao/workspaces/spreadconfig/skills/local/<skill-name>
```

If `skills/sources.nix` changed, format it and check the diff:

```bash
nixfmt /home/spreadzhao/workspaces/spreadconfig/skills/sources.nix
git -C /home/spreadzhao/workspaces/spreadconfig diff --check
```

For Git-backed flake evaluations, remember that newly created files may be invisible to Nix until they are added to the Git index. If an eval or switch must see new skill files, stage only the relevant new skill files and registry changes; do not stage unrelated dirty work.
