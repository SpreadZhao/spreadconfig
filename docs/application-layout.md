# Application configuration and host differences

Application modules own their native files and scripts. Shared configuration lives
in `modules/home/<app>/files/`, next to `default.nix`; host fragments live in
`hosts/<host>/home/<app>/`. Pure Nix modules without external assets can remain
single `.nix` files. The Home Manager entry point imports only top-level modules
and direct child `default.nix` files, and rejects duplicate file/directory modules.

## Configuration ownership

An application's module also owns its session variables, script PATH entries,
MIME and protocol associations, desktop entries, autostart overrides, user
services, and application-specific directories. Portal implementations own their
backend registrations. Keep the existing variable names, installed paths and
service dependencies when moving these declarations.

`home-core.nix` contains user identity and general shell settings. `xdg.nix`
contains XDG infrastructure, common directory conventions, the default portal
policy, and the ordered desktop-wide MIME fallback package list. Its Antigravity
association remains there because that application has no managed module.
`vars.nix` remains the shared source of theme values, paths and link helpers;
personal shell aliases remain in the shell module.

Script PATH declarations use explicit ordering: niri (100), shared tools (200),
Nix tools (300), then the general `.local/bin` entry at the default priority.
These priorities preserve the existing executable lookup order independently of
module import order.

Draw.io's custom MIME package is defined in `drawio/mime.nix`. The small
`xdg-drawio.nix` import adapter keeps that package in its original position in
`home.packages`, preserving both the generated profile and Fontconfig directory
order. Its MIME associations and application package remain in `drawio/default.nix`.

When a feature needs both module systems, use matching names in `modules/home`
and `modules/nixos`: for example, Polkit's user authentication agent belongs in
Home Manager while its system authorization service belongs in NixOS. Keep
host-specific service policies in separate host leaf modules, such as TLP,
asusd, supergfxd and LACT, with explicit imports from the host entry point.

Ownership refactors must preserve evaluated values and generated file contents
across every affected host. Compare against the current working tree, including
uncommitted application changes, rather than against Git HEAD. In particular,
check ordered lists, package sets, MIME precedence and service dependencies;
successful evaluation alone does not establish equivalence.

The arrangement follows the application-local assets and host-selected include
pattern in [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config/blob/01e93c2b65fa51f331f1d82a25fefab30c08490d/home/linux/gui/niri/default.nix)
and the application folders in [dbeley/nixos-config](https://github.com/dbeley/nixos-config/blob/bd4cef2041d237277d1b8700d40852676af73461/apps/tmux/tmux.nix).
`lib/host-context.nix` constructs and validates the shared host context before
NixOS or Home Manager module evaluation. Host declarations and profiles supply
hardware facts and policy; the constructor supplies shared defaults. It remains
available as `spreadconfig.lib.mkHost`.

## Selecting host differences

- Niri: each host's Home Manager module sets
  `spreadconfig.apps.niri.hostConfig` to its repository-relative `host.kdl`.
  The shared entry includes the host fragment and common settings. Complete
  input sections, outputs, GPU settings and the Zephyrus Waydroid rule remain
  host-owned. Repeated window rules retain their order; outputs are not merged.
- Qutebrowser: `spreadconfig.apps.qutebrowser.hostConfig` defaults to an empty
  shared `host.py`. Zephyrus selects its native GPU/font/zoom overrides, sourced
  after shared assignments and before theme setup. Package renderer and scale
  still come from `host.profile.home.qutebrowser`.
- Waybar: `host.profile.home.waybar` contains `height`, `fontSize`, and
  `temperaturePath` (null disables the sensor layout). Battery layout follows
  `host.capabilities.battery == true`. Small generated entry files select the
  shared native JSONC/CSS and supply overrides. Waybar's including file has
  priority over included values; CSS font overrides follow the shared import.

Qutebrowser's `autoconfig.yml` remains application-managed, and quickmarks keep
their independent password-store link. Do not replace the whole qutebrowser
configuration directory with a source directory.

## Editable links and script ownership

`lib/mutable-files.nix` exposes three module arguments:

- `repoLink relativePath`: validate a repository file and link to the actual
  checkout using `mkOutOfStoreSymlink`.
- `repoEntries relativeDirectory`: enumerate a directory into a target/source
  map. Only explicitly selected asset directories are enumerated.
- `repoTree name entries`: assemble a store directory of links, rejecting unsafe
  target paths and file/directory target conflicts. Generated Nix files may also
  be supplied as entries.

Evaluation checks use `repoRoot`; runtime links use the editable `projDir`
string. Editing an existing native source is visible on application reload.
Adding/removing a managed file or changing Nix-generated parameters requires a
new build and activation. Directory roots retain their existing store-backed,
read-only shape; mutable source contents are not restored by generation rollback.

Applications register their scripts through `spreadconfig.scriptFiles`, using
`repoEntries` on their `scripts/` directory. The shared script module assembles
one tree at `~/scripts`. Runtime names, PATH entries and executable modes are
preserved. Conflicting source definitions are errors.

| Owner | Installed paths/content |
| --- | --- |
| niri | `niri/`, including compositor-specific terminal and screenshot workflows |
| qutebrowser | `qutebrowser/translate`, also installed as a browser userscript |
| nix-tools | `nix/`, shared maintenance commands and input exclusions |
| zsh, fzf | Shell initialization and fzf preview entry under `config/` |
| lf | `util/lf-wrapper*` |
| waybar | Battery, brightness and recording/time helpers |
| git | Git AI commands and their `util/lib` / `util/config` dependencies |
| pass, wl-clipboard, wechat | Password menus, copy-file and WeChat launcher |
| mpv, ffmpeg | Camera and video-to-audio helpers |
| script-tools | Shared host context/preview and audio helper |

Scripts that need checkout-relative resources resolve their own source through
installed symlinks and use the `modules/home/<app>/scripts/` layout to load
`script-tools/scripts/config/host_context.sh`. This shared initializer locates a
parent containing both `flake.nix` and `hosts/` once, exposes it as
`SPREADCONFIG_SOURCE_ROOT`, and loads the generated host context from
`${XDG_CONFIG_HOME:-$HOME/.config}/spreadconfig/host.sh`. No fixed parent depth is
assumed. Maintenance commands preserve their explicit host/repository overrides;
`nix_update` defaults to the source checkout. The skill resolver validates the
host, then returns the shared nix-tools source.

## Validation

Use path flakes while new files are untracked; normal Git-backed flakes require
new sources to be tracked. Do not put plaintext private keys in any flake source.

```sh
nixfmt flake.nix
git diff --check
nix eval --raw "path:$PWD#nixosConfigurations.desktop1.config.home-manager.users.spreadzhao.home.activationPackage.drvPath"
```

Evaluate the Home Manager activation package and system for all three hosts,
using each host’s existing disk configuration. Build the affected asset/link-tree
sources without activation, check their final destinations and permissions, and
run `niri validate -c <built-tree>/config.kdl` on every Niri tree.

For changed Shell scripts, run syntax checks and ShellCheck.
