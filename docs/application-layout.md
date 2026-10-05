# Application configuration and host differences

Application modules own their native files and scripts. Shared configuration lives
in `modules/home/<app>/files/`, next to `default.nix`; host fragments live in
`hosts/<host>/home/<app>/`. Pure Nix modules without external assets can remain
single `.nix` files. The Home Manager entry point imports only top-level modules
and direct child `default.nix` files, and rejects duplicate file/directory modules.

The arrangement follows the application-local assets and host-selected include
pattern in [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config/blob/01e93c2b65fa51f331f1d82a25fefab30c08490d/home/linux/gui/niri/default.nix)
and the application folders in [dbeley/nixos-config](https://github.com/dbeley/nixos-config/blob/bd4cef2041d237277d1b8700d40852676af73461/apps/tmux/tmux.nix).
The existing host constructor and profiles remain the source of hardware facts
and policy; no new flake framework is required.

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
| waybar | Battery, brightness, recording/time and round-info helpers |
| git | Git AI commands and their `util/lib` / `util/config` dependencies |
| agent-skills | `util/check-skills.sh` |
| pass, wl-clipboard, wechat | Password menus, copy-file and WeChat launcher |
| mpv, ffmpeg | Camera and video-to-audio helpers |
| script-tools | Shared host context/preview, audio/wallpaper helpers, retained `legacy/`, `sway/` |

Scripts that need checkout-relative resources locate a parent containing both
`flake.nix` and `hosts/`; they do not assume a fixed source depth. Maintenance
commands preserve explicit host/repository overrides and generated host context.
The skill resolver validates the host, then returns the shared nix-tools source.

## Validation

Use path flakes while new files are untracked; normal Git-backed flakes require
new sources to be tracked. Do not put plaintext private keys in any flake source.

```sh
nixfmt flake.nix
git diff --check
nix eval --raw "path:$PWD#nixosConfigurations.desktop1.config.home-manager.users.spreadzhao.home.activationPackage.drvPath"
```

Evaluate the Home Manager activation package for all four hosts and the system
for desktop1, thinkbook and zephyrus-m16. The amd-desktop disk placeholder must
continue blocking a full system evaluation. Build the affected asset/link-tree
sources without activation, check their final destinations and permissions, and
run `niri validate -c <built-tree>/config.kdl` on every Niri tree.

For changed Shell scripts, run syntax checks and ShellCheck.
