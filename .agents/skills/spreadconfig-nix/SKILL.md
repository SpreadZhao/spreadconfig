---
name: spreadconfig-nix
description: Maintain the spreadconfig multi-host NixOS repository. Use for installing or removing applications, changing Home Manager or NixOS modules, editing host-specific settings, updating flakes, rebuilding or switching systems, cleaning generations, and deciding which spreadconfig/scripts/default/nix or spreadconfig/scripts/HOST/nix script to run for the current host.
---

# Spreadconfig Nix

## Core Rules

- Work from the repo root `/home/spreadzhao/workspaces/spreadconfig`.
- Check `git status --short` first. Preserve unrelated user changes and staged files.
- Determine the target host before host-specific edits. Prefer an explicit user-provided host; otherwise use `hostname -s`. Valid hosts are directories under `hosts/`.
- Keep shared modules in `modules/home` or `modules/nixos`. Put host-only settings under `hosts/<host>/home`, `hosts/<host>/nixos`, `spreadconfig/config/<host>`, or `spreadconfig/scripts/<host>`.
- `modules/home/default.nix` and `modules/nixos/default.nix` auto-import regular `.nix` files in those directories. A new app module such as `modules/home/drawio.nix` is enough.
- For Git-backed flakes, new files are invisible to `nix eval` until they are tracked. Run `git add <new-file>` before verifying new modules or new host files.

## Common Changes

- User app install: add `modules/home/<name>.nix` with `home.packages = [ pkgs.<pkg> ];`.
- System package or service: add or edit `modules/nixos/<name>.nix` for shared behavior, or `hosts/<host>/nixos/*.nix` for host-only behavior.
- Host-linked config: edit `spreadconfig/config/<host>/...` when only one host should change; edit `spreadconfig/config/default/...` for shared defaults.
- Host-linked scripts: edit `spreadconfig/scripts/<host>/...` when only one host should change; edit `spreadconfig/scripts/default/...` for shared defaults.
- New host support: add `hosts/<host>` plus `spreadconfig/scripts/<host>/nix/sns` and `sns_until` pointing to `path://$HOME/workspaces/spreadconfig#<host>`.

## Validation

After Nix edits:

1. Run `nixfmt` on changed `.nix` files.
2. Run `git diff --check`.
3. Evaluate the affected host. Useful checks:
   - `nix eval --json .#nixosConfigurations.<host>.config.home-manager.users.spreadzhao.home.packages`
   - `nix eval --raw --no-eval-cache .#nixosConfigurations.<host>.config.home-manager.users.spreadzhao.home.activationPackage.drvPath`
   - `nix eval --raw --no-eval-cache .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
4. For shared modules, evaluate all hosts unless the change is clearly host-gated.

Do not apply the system unless the user asks to apply, switch, boot, update, or rebuild.

## Applying Or Updating

Runtime scripts are installed at `~/scripts/nix` from merged `spreadconfig/scripts/default` and `spreadconfig/scripts/<host>`. Prefer these when applying on the current machine:

- Apply current config: `~/scripts/nix/sns_until switch`
- Build for next boot: `~/scripts/nix/sns_until boot`
- Update flake and build: `~/scripts/nix/nix_update boot`
- Full update plus cleanup: `~/scripts/nix/nix_full_update boot`
- Clean generations: `~/scripts/nix/nix_clean boot`

When operating from the repo, use `scripts/resolve-nix-script` to choose the correct source script:

```bash
skills/spreadconfig-nix/scripts/resolve-nix-script sns_until
skills/spreadconfig-nix/scripts/resolve-nix-script nix_update
SPREADCONFIG_HOST=thinkbook skills/spreadconfig-nix/scripts/resolve-nix-script sns
```

The resolver prefers `spreadconfig/scripts/<host>/nix/<name>` and falls back to `spreadconfig/scripts/default/nix/<name>`.

Use `switch` for ordinary Home Manager or service changes the user wants now. Use `boot` for kernel, NVIDIA, boot, filesystem, generation cleanup, or broad update work unless the user explicitly wants a live switch.
