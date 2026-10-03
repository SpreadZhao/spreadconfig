---
name: spreadconfig-nix
description: Maintain the spreadconfig multi-host NixOS repository. Use for installing or removing applications, changing Home Manager or NixOS modules, editing host-specific settings, updating flakes, rebuilding or switching systems, cleaning generations, debugging Nix eval/build failures including fixed-output hash mismatches, and resolving shared modules/home/nix-tools/scripts/nix maintenance scripts for the target host.
---

# Spreadconfig Nix

## Workspace Scope

- Resolve the target repository from an explicit request or `SPREADCONFIG_REPO`. Otherwise the resolver discovers a checkout containing `flake.nix` and `hosts/` from the current directory, Git root, or actual skill source's ancestors. Change into the selected repository before running git, Nix, or maintenance commands.
- Workspace skill selection does not identify a target configuration repository; use `--repo` when the task names a different checkout from the skill's source.
- Resolve bundled helpers relative to the loaded skill directory. The workspace and repository need not share a parent or contain their own installed skill copies.

## Core Rules

- Work from the resolved repository root.
- Check `git status --short` first. Preserve unrelated user changes and staged files. If a related file is already dirty, inspect the diff before editing it.
- Determine the target host before host-specific edits. Prefer an explicit user-provided host; otherwise use `hostname -s`. Valid hosts have `hosts/<host>/host.nix`; `hosts/lib` is the shared constructor, not a host.
- Each `host.nix` declares hardware facts, profile imports, and NixOS/Home Manager module lists. `hosts/lib/default.nix` constructs the same `host` argument for both module systems before module evaluation. Shared modules read `host.cpu`, `host.gpu`, `host.capabilities`, and `host.profile`; prefer capability checks to repeated host name lists. CPU vendor does not imply GPU vendor, and `null` capabilities mean unknown.
- Keep shared modules in `modules/home` or `modules/nixos`. Put host policies in `hosts/<host>/{home,nixos}/profile.nix`, hardware-specific leaf modules under the same directories, and application assets under `modules/home/<app>/{files,scripts}`. Host native fragments live in `hosts/<host>/home/<app>/`. Preserve generated `hardware-configuration.nix` format. Niri monitor layouts stay in per-host KDL files.
- `modules/home/default.nix` imports top-level `.nix` files and direct child directories containing `default.nix`; never keep both `<app>.nix` and `<app>/default.nix`. NixOS still imports top-level `.nix` modules. Plain package-only modules may remain single files.
- Git-backed flakes omit untracked files. For work in progress, verify using `nix eval "path:$PWD#..." --no-write-lock-file` (or an equivalent path flake) so new files are included without changing the user’s index. Normal Git-backed evaluation requires new files to be tracked.

## Common Changes

- User app install: add `modules/home/<name>.nix` with `home.packages = [ pkgs.<pkg> ];`.
- System package or service: add or edit `modules/nixos/<name>.nix` for shared behavior, or `hosts/<host>/nixos/*.nix` for host-only behavior.
- Shared native config: edit `modules/home/<app>/files/`. Use `repoLink` for one file, `repoEntries` for a directory mapping, and `repoTree` to preserve an existing directory deployment. Pass repository-relative paths; runtime links must target the editable checkout, not the store copy.
- Host config: put numeric and boolean policy in `home/profile.nix`; select native fragments through `spreadconfig.apps.<app>.hostConfig` in the host Home Manager module. Public config loads fixed fragment names, without host-name branches.
- Scripts: edit the owning app’s `scripts/` tree and register with `spreadconfig.scriptFiles`. Preserve installed `~/scripts/...` paths. Shared libraries live in `script-tools`; maintenance commands live in `nix-tools`. Never infer the checkout root from a fixed number of parent directories.
- New host support: create `hosts/<host>/host.nix` with `system`, `formFactor`, independent CPU/GPU facts, capabilities, profile imports, and module lists. Add real generated disk configuration and a per-host niri config. Shared `sns`/`sns_until` read the Home Manager-generated `~/.config/spreadconfig/host.sh`; do not duplicate these scripts per host. `SPREADCONFIG_HOST` selects an explicit target when running repository scripts for another machine.

## Validation

After Nix edits:

1. Run `nixfmt` on changed `.nix` files. If `nixfmt` is not available in the current shell, use `nix develop -c nixfmt <files>`.
2. Run `git diff --check`.
3. Evaluate the affected host or hosts. Useful checks:
   - `nix eval --json .#nixosConfigurations.<host>.config.home-manager.users.spreadzhao.home.packages`
   - `nix eval --raw --no-eval-cache .#nixosConfigurations.<host>.config.home-manager.users.spreadzhao.home.activationPackage.drvPath`
   - `nix eval --raw --no-eval-cache .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
4. For shared `modules/home` changes, evaluate the Home Manager activation package for every host. For shared `modules/nixos` changes, evaluate the system toplevel for every host. For host-specific changes, evaluate only that host unless shared dependencies changed.
5. For asset changes, run `nix build --no-link .#checks.x86_64-linux.mutable-files`, `python3 tests/app-configs.py`, and `python3 tests/host-scripts.py`; validate each affected niri tree with `niri validate -c <tree>/config.kdl`. Confirm active links resolve to the application-owned sources.
6. For host declarations or constructor changes, run `nix build --no-link .#checks.x86_64-linux.host-context`. The `amd-desktop` disk placeholder intentionally blocks its full system evaluation until replaced; verify its host policy and Home Manager separately without weakening that assertion.

If eval or build fails because Nix cannot access the user fetcher cache or another sandboxed cache path, rerun the same command with the required approval instead of treating it as a configuration failure.

Do not apply the system unless the user asks to apply, switch, boot, update, or rebuild.

## Failure Handling

- For fixed-output hash mismatches, first identify whether the hash is defined in this repo or inside an external flake input. If the input is not current, update it. If latest upstream is still broken, prefer a small local override or `pkgs.applyPatches` patch over vendoring the whole upstream source.
- For flake path errors after adding files, check whether the file is Git-tracked before changing Nix code.
- For scripts that fail without output, run with shell tracing or inspect the reported line number before rewriting logic.

## Applying Or Updating

Runtime scripts are installed at `~/scripts/nix` from `modules/home/nix-tools/scripts/nix`. All hosts use the same commands and generated host context. Prefer these when applying on the current machine:

- Apply current config: `~/scripts/nix/sns_until switch`
- Build for next boot: `~/scripts/nix/sns_until boot`
- Update flake and build: `~/scripts/nix/nix_update boot`
- Full update plus cleanup: `~/scripts/nix/nix_full_update boot`
- Clean generations: `~/scripts/nix/nix_clean boot`

When operating from the repo, resolve bundled helpers from the active skill
directory, not from a repo-local `.agents/skills` directory:

```bash
SKILL_DIR="<directory containing this SKILL.md>"
"$SKILL_DIR/scripts/resolve-nix-script" sns_until
"$SKILL_DIR/scripts/resolve-nix-script" nix_update
SPREADCONFIG_HOST=thinkbook "$SKILL_DIR/scripts/resolve-nix-script" sns
```

The resolver accepts `--repo` before `SPREADCONFIG_REPO` and checkout discovery, in that order. It validates the selected host and returns `modules/home/nix-tools/scripts/nix/<name>`.

Use `switch` for ordinary Home Manager or service changes the user wants now. Use `boot` for kernel, NVIDIA, boot, filesystem, generation cleanup, or broad update work unless the user explicitly wants a live switch.
