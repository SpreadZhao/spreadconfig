# Skill Registry

This directory is the declarative source registry for agent skills.

- Put local skill sources under `skills/local/<name>/`.
- Register global skills in `skills/sources.nix` under `globalSkills`.
- Register dynamic workspace profiles in `skills/sources.nix` under
  `workspaceProfiles`.
- Each skill declares its own `targets`; valid targets are `agents`, `claude`,
  and `codex`.

Local skills live in `skills/local/<name>/`. Home Manager installs these as
direct symlinks to the working tree path under `$HOME/workspaces/spreadconfig`,
so editing a local skill changes the installed skill immediately after the
initial symlink has been created. Prefer flake inputs or fixed-output fetchers
for skills with a clear upstream so the skill source does not need to be
vendored into this repository.

Missing-directory policies:

- `create`: create the target directory as part of Home Manager file linking.
- `fail`: fail activation if the target directory does not already exist.
- `skip`: skip installing that directory's skills if the target directory does
  not already exist.

Skill targets fail on existing files by default. Set `force = true` on a
specific skill only when overwriting an existing target is intentional.

Dynamic workspace profiles:

- Home Manager writes the generated manifest to
  `~/.config/spreadconfig/agent-skill-profiles.tsv`.
- Use `agent-skills use <profile...>` to replace the active symlink set under
  `~/workspaces` without rebuilding.
- Use multiple profiles together, such as `agent-skills use base leetcode` or
  `agent-skills use base android frontend`.
- Use `agent-skills add <profile...>` and `agent-skills remove <profile...>`
  for incremental changes.
- The dynamic switcher only removes symlinks it previously managed. Existing
  non-symlink skill directories are left alone unless `agent-skills --force`
  is used.
- Workspace profile targets are expanded from each skill's `targets` field:
  `agents` -> `~/workspaces/.agents/skills`,
  `claude` -> `~/workspaces/.claude/skills`,
  `codex` -> `~/workspaces/.codex/skills`.
- Keep always-available global skills in `globalSkills`. Put
  project/domain-specific skills in workspace profiles instead of installing
  them into each project directory.

Example:

```nix
let
  mySkill = {
    my-skill = {
      source = localSkillSource "my-skill";
      targets = [
        "agents"
        "claude"
      ];
    };
  };
in
{
  globalSkills = [
    mySkill
  ];

  workspaceProfiles.notes = [
    mySkill
  ];
};
```
