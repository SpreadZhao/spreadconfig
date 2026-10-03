# Workspace

Edit `flake.nix` to select `skills` and `packages`, then run `nix develop`.
`claude = true` adds Claude entries; `instructions` adds text to `AGENTS.md`.

Each selected skill uses its defined source. Local catalog skills use the central
checkout named by `SPREADCONFIG_SOURCE_ROOT` (provided by spreadconfig's Home
Manager configuration). Upstream and `extraSkills` entries use their supplied
sources. `extraSkills.my-skill = ./skills/my-skill;` adds a custom skill.

Activation prepares the selected `.agents/skills` links, `AGENTS.md`, and private
`.agent-workspace` state/GC roots. Existing unrelated skills and files remain in
place; a conflicting target is reported before changing entries. Reenter after
changing selections. Central local skill content edits are visible immediately.

Start agents from this workspace root; a separately opened nested Git repository
may have a different skill-discovery root. See `docs/workspaces.md` in spreadconfig
for the complete interface and validation commands.
