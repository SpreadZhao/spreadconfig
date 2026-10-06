# Skill catalog

Personal content now lives in the sibling `personal-skills/skills/<name>/`
repository. `sources.nix` retains the catalog, upstream transformations and
`globalSkills` selection. Personal and third-party sources are ordinary locked
flake inputs; no checkout environment variable or `relativePath` is used.
See [workspace setup](../docs/workspaces.md).

Register source sets under `skillSets`; select project names with `skills` and
additional sources with `extraSkills`. Each record has `source`, optional
`subdir` and optional `targets`. Skills without target restrictions use every
enabled target. The existing global selection remains drawio-skill and
yt-dlp-downloader, with agents and Claude targets.

Home Manager imports the independent agent-workspace module. Its default
`onConflict = "skip"` installs each missing skill separately and creates missing
parent directories. Existing directories, files and conflicting links (including
dangling links) remain intact. Identical results are unchanged; external entries
are never adopted. Global cleanup defaults to false.

Workspace defaults are `onConflict = "error"` and `cleanup = true`.
Both installations share one engine and the same configuration field.
Update a source input to adopt content changes; remove only the specific old
entry before installation if its source changed. No automatic replacement occurs.

The six paper skills and android-dev are normal personal input sources.
Business paths follow the skill's configuration or the current request.
Validate changed metadata with skill-creator's quick_validate.py.
`~/scripts/util/check-skills.sh` remains available to inspect skill directories.
