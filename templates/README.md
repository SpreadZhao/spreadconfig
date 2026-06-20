# Development Templates

This directory contains flake templates for bootstrapping project-local
development environments.

Use a template in a new project:

```bash
nix flake new -t ~/workspaces/spreadconfig#android my-android-project
```

Use a template in the current directory:

```bash
nix flake init -t ~/workspaces/spreadconfig#android
```

Each template can include more than packages. Project-local agent skills live
under `.agents/skills`, so agents can discover workflow-specific instructions
when they run inside the generated project.
