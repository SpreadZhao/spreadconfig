# Workspace templates

`workspace` is the default template. It selects skills and tools through
`agent-workspace.lib.mkWorkspace`, passing `spreadconfig.lib.skillCatalog` explicitly.
`android` extends the same implementation with Android tools and official skills.

```bash
nix flake new -t github:SpreadZhao/spreadconfig#workspace my-workspace
# Or, inside an existing empty directory:
nix flake init -t github:SpreadZhao/spreadconfig#android
```

For the current local extraction, initialize from
`git+file:///home/spreadzhao/workspaces/spreadconfig` and override the generated
workspace's spreadconfig input to that path. The two sibling inputs are local
and have not been published. The manager input follows `spreadconfig/agent-workspace`.
A generic template also lives in agent-workspace; see
[the complete workflow](../docs/workspaces.md). Templates contain no skill copies.
`nix develop` prepares the selected links. No separate installer or profile CLI is
needed, and business repositories are never created or moved automatically.
