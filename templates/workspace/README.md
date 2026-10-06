# Workspace

Select skills and packages in flake.nix, then run nix develop.
spreadconfig.lib.mkWorkspace forwards to the independent agent-workspace manager
with spreadconfig's catalog. Personal and third-party content are locked inputs.

claude = true enables Claude targets and CLAUDE.md; instructions appends text to
AGENTS.md. Existing instructions conflict by default; manageInstructions = false
or onConflict = "skip" preserves them. Missing skill entries are installed
individually. cleanup = true removes only unchanged owned deselected entries.

For current local use, override the spreadconfig input to
path:/home/spreadzhao/workspaces/spreadconfig before entering.
Changing a source requires updating its input and removing the specific old
entry when it conflicts. See docs/workspaces.md in spreadconfig for the complete
interface and the independent generic template.
