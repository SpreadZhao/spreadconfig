---
name: spreadconfig-skill-authoring
description: Create or update skills in the spreadconfig catalog. Use when the user asks to author, register, expose, or select skills under skills/local or skills/sources.nix, configure a workspace flake's skills, or maintain Home Manager global skill links.
---

# Spreadconfig Skill Authoring

Use this skill with `$skill-creator` for skill design and validation. This skill
covers the central catalog and project-local declarative selection.

## Source and Workspace

Use the central source repository identified by the user's request or current
project context. When this skill is linked from that checkout, discover it from
the actual skill source's ancestors and verify `skills/sources.nix` exists.
The consuming workspace can live anywhere; selecting skills does not configure
notes, code repositories, or other business destinations.

- Edit local content at `<source-repository>/skills/local/<skill-name>/`.
- Register sources in `<source-repository>/skills/sources.nix`.
- `catalog` exports names mapped to skill source records. Each record determines its own source: central local skills use the fixed central checkout; upstream or custom skills use their declared Nix input or path.
- A workspace's own `flake.nix` selects names with `skills = [ "skill-name" ];` through `spreadconfig.lib.mkWorkspace`.
- `extraSkills` adds explicitly declared custom sources for that workspace.
- `globalSkills` remains the separate Home Manager selection for home-level links.

## Creating or Updating a Skill

1. Read the existing catalog and nearby skill structure. Choose a lowercase hyphenated name of at most 64 characters.
2. For a new skill, use the loaded `$skill-creator` initializer when available:

   ```bash
   CREATOR_DIR="<loaded skill-creator directory>"
   SOURCE_ROOT="<central source repository>"
   python3 "$CREATOR_DIR/scripts/init_skill.py" <skill-name> --path "$SOURCE_ROOT/skills/local"
   ```

3. Keep `SKILL.md` concise, preserve an existing skill's behavior unless requested otherwise, and add scripts or references only when needed. Keep `agents/openai.yaml` aligned with its name and trigger; the default prompt should mention `$<skill-name>`.
4. Register the skill in `skills/sources.nix`, following an adjacent catalog entry. Local skills use `localSkillSource "<skill-name>"` and their repository-relative source path; upstream skills use an explicit flake input. Include any new set in `skillSets`, whose entries form the catalog. `globalSkills` selects skills exposed at home level.
5. Select project skills in that workspace's flake, for example:

   ```nix
   outputs = { spreadconfig, ... }: spreadconfig.lib.mkWorkspace {
     systems = [ "x86_64-linux" ];
     skills = [ "my-skill" "spreadconfig-nix" ];
   };
   ```

   The supported workspace options are `systems`, `skills`, `extraSkills`, `packages`, `claude`, `instructions`, and `shellHook`. Source selection belongs to each skill's catalog or custom-source declaration.
6. When renaming or moving a skill, update the directory, frontmatter name, interface metadata, catalog source, and affected selectors together.

## Applying and Validating

- Existing local links reflect source-content edits immediately. For changed selections, re-enter the workspace with `nix develop` or reload its direnv environment. To update an upstream skill, update its declared input when requested.
- Workspace selections do not require a Home Manager or NixOS switch. Changes to `globalSkills` still require the user's Home Manager application step. Do not apply a system or global configuration unless the user requests it.
- Validate each changed skill with the loaded creator's `scripts/quick_validate.py`, and test any changed helper behavior with temporary fixtures.

   ```bash
   python3 "$CREATOR_DIR/scripts/quick_validate.py" "$SOURCE_ROOT/skills/local/<skill-name>"
   nixfmt "$SOURCE_ROOT/skills/sources.nix"
   git -C "$SOURCE_ROOT" diff --check
   ```

For work in progress, use a `path:` flake reference and `--no-write-lock-file`
when evaluating untracked files. Preserve the user's index; do not stage files
merely to make them visible to a Git-backed flake.
