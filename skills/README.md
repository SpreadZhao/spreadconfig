# Skill catalog

`local/<name>/` contains the skills maintained here. `sources.nix` exposes a
`catalog` mapping selectable names to their sources. A workspace selects names
with `skills = [ "leetcode-coach" "obsidian-markdown" ];` through `mkWorkspace`.
See [workspace setup](../docs/workspaces.md).

Each catalog entry fixes its source. Local entries carry a `relativePath`,
resolved under `SPREADCONFIG_SOURCE_ROOT`; their Nix `source` is also checked at
build time. Upstream entries use their declared source. `extraSkills` accepts
additional name/source mappings in the workspace's flake.

Register new catalog sets under `skillSets`. `globalSkills` remains the small
Home Manager selection, with `targets` choosing home-level agents/Claude entries.
Workspace skills use `.agents/skills` and optionally Claude.

The six paper skills are ordinary local skills. Their regression test is
`tests/paper-workspace.py`. `android-dev` lives here and is selected by the Android
template. Business paths use each skill's own configuration or the current task.

Validate changed metadata with skill-creator's `quick_validate.py`.
`~/scripts/util/check-skills.sh` is also available to inspect skill directories.
