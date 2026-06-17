# Skill Registry

This directory is the declarative source registry for Codex skills.

- Put local skill sources under `skills/local/<name>/`.
- Register install targets in `skills/sources.nix` under `skillDirs`.
- Each `skillDirs` key is a Home Manager file target relative to `$HOME`, such
  as `.agents/skills`, `.claude/skills`, or any other skill directory.
- Each `skillDirs` value can be one skill attrset or a list of skill attrsets.
- Use `{ onMissing = "..."; skills = ...; }` when a target directory needs an
  explicit missing-directory policy.

Local skill snapshots live in `skills/local/<name>/` when there is no pinned
external source or the currently installed version should be preserved exactly.
Prefer flake inputs or fixed-output fetchers for skills with a clear upstream so
the skill source does not need to be vendored into this repository.

Missing-directory policies:

- `create`: create the target directory as part of Home Manager file linking.
- `fail`: fail activation if the target directory does not already exist.
- `skip`: skip installing that directory's skills if the target directory does
  not already exist.

Skill targets fail on existing files by default. Set `force = true` on a
specific skill only when overwriting an existing target is intentional.

Example:

```nix
skillDirs = {
  ".agents/skills" = {
    onMissing = "create";
    skills = [
      commonSkills
      localSkills
    ];
  };

  "workspaces/SecondBrain/.agents/skills" = {
    onMissing = "fail";
    skills = {
      my-skill.source = ./local/my-skill;
    };
  };
};
```
