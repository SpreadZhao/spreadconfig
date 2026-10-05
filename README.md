# My NixOS Config

My personal NixOS configuration, built with [flakes](https://wiki.nixos.org/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). Designed for a terminal-centric, Wayland-first developer workflow with a unified dark color scheme across every application.

<img width="1920" height="1080" alt="Screenshot_DP-2_20260227_000645" src="https://github.com/user-attachments/assets/fddcf456-6f25-4798-89ab-ee930262a981" />

## Repository Structure

```
.
├── flake.nix                       # Flake entry point
├── lib/mutable-files.nix           # Checked workspace links and explicit file trees
├── lib/workspace/                  # mkWorkspace and internal shell activation
├── templates/                      # Independent workspace and Android skeletons
├── skills/                         # Skill catalog and local sources
├── hosts/
│   ├── lib/default.nix             # Shared host facts and profile defaults
│   └── <host>/
│       ├── host.nix                # Hardware declaration and module lists
│       ├── configuration.nix       # Host NixOS entry point
│       ├── hardware-configuration.nix
│       ├── home.nix                # Host Home Manager entry point
│       ├── home/
│       │   ├── profile.nix         # Fonts, Waybar and other host parameters
│       │   ├── niri/               # Display/input/GPU configuration
│       │   └── qutebrowser/        # Optional host Python settings
│       └── nixos/                  # Host hardware, identity and services
├── modules/
│   ├── nixos/                      # Shared system modules
│   └── home/
│       ├── default.nix             # Imports .nix modules and app/default.nix
│       ├── vars.nix                # Theme, fonts, runtime paths and link helpers
│       ├── home-core.nix           # Home identity and session settings
│       ├── script-files.nix        # Assembles the existing ~/scripts interface
│       ├── <app>/
│       │   ├── default.nix         # Application configuration
│       │   ├── files/              # Handwritten application assets
│       │   ├── scripts.nix         # Optional script installation declarations
│       │   └── scripts/            # Scripts under their installation paths
│       ├── nix-tools/              # Shared Nix maintenance commands
│       └── script-tools/           # Common script libraries and retained tools
├── scripts/sops-key                # Secret bootstrap helper
├── tests/                          # Host, script, asset and workspace checks
└── secrets/                        # Encrypted secrets and ignored local identities
```

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | NixOS unstable (primary package set) |
| `nixpkgs-desktop1-graphics` | desktop1's known working kernel/NVIDIA/niri/Mesa package set |
| `home-manager` | User environment management |
| `nixos-hardware` | Hardware presets for supported laptops |
| `nixvim` | Declarative Neovim configuration |

## Hosts

### desktop1

Intel/NVIDIA desktop migrated from the `nixos_desktop1` branch. Uses the shared configuration on `nixos`, preserving its original disk UUIDs and direct NVIDIA graphics setup. No ASUS laptop services or PRIME offload are enabled.

**Before the first rebuild:** initialize the shared age identity with `./scripts/sops-key init`. Enter the shared identity passphrase once; subsequent boots and rebuilds use the root-only local key. Sync the encrypted identity file together with the configuration. See [SOPS setup](docs/sops.md).

### amd-desktop

Planned Ryzen 9 9950X3D / Radeon RX 9070 XT desktop. Reuses all shared system and Home Manager modules, with AMD hardware policy and LACT only. The hardware placeholder intentionally blocks installation until replaced with the new machine's generated configuration.

See [the host setup guide](hosts/amd-desktop/README.md) for disk configuration, SOPS initialization, display setup, and installation.

### thinkbook

My primary laptop — AMD CPU/GPU with a Wayland-native desktop stack.

- **Boot**: systemd-boot with v4l2loopback (OBS virtual camera)
- **Login**: greetd with agreety, auto-starts niri
- **Audio**: PipeWire
- **GPU**: AMD with OpenCL support, managed via LACT

### zephyrus-m16

ASUS ROG laptop — Intel CPU with NVIDIA hybrid graphics.

- **Hardware preset**: nixos-hardware ASUS Zephyrus GU603H module
- **GPU**: Intel/NVIDIA PRIME offload with Dynamic Boost
- **ASUS controls**: asusd and supergfxd
- **Power**: Host-specific TLP charging policy

### Host declarations and shared modules

Each `hosts/<name>/host.nix` declares `system`, `formFactor`, CPU and GPU facts,
hardware capabilities, profile imports, and NixOS/Home Manager module lists.
`hosts/lib/default.nix` builds a single `host` value before either module system
is evaluated. Both receive this value through their special arguments.

Shared modules use normal Nix expressions such as `lib.mkIf host.gpu.hasNvidia`
and read policy from `host.profile.nixos` or `host.profile.home`. The tool layer
provides `host.name`, `host.is "desktop1"`, CPU vendor predicates, independent GPU
vendor predicates, and `host.isLaptop`/`host.isDesktop`. A hybrid GPU declaration
can set multiple GPU predicates. Unknown CPU families and hardware capabilities
are `null`; an Intel CPU alone does not establish that the machine has an Intel GPU.

The AMD hosts retain ROCm/OpenCL support; the NVIDIA hosts disable global ROCm
support. GPU package choices follow the declared hardware and application needs.
Qutebrowser rendering and scale, OBS plugins, camera/device paths, and optional
services are profile values. The existing Zephyrus Intel Vulkan workaround
requires an actual Intel GPU. Concrete PCI addresses, driver pins, fan curves,
and other machine-specific fixes remain in host leaf modules. Niri display
layouts and input settings stay in `hosts/<host>/home/niri/host.kdl`.

To add a host, create its declaration and profile files, list its host-only
modules, supply the machine's generated `hardware-configuration.nix`, and create
its niri Home Manager module and native fragment. Host directories are discovered
by the presence of `host.nix`.
Do not copy `sns` or `sns_until`: the shared scripts read
`~/.config/spreadconfig/host.sh`, generated by Home Manager from the declaration.
Use `SPREADCONFIG_HOST=<name>` when explicitly targeting another host.

Run `nix build --no-link .#checks.x86_64-linux.host-context` for host semantic
checks, then evaluate the affected system and Home Manager outputs. The
`amd-desktop` disk placeholder intentionally blocks its complete system until
real disk information is supplied; its host context and Home Manager can be checked
independently.

## Desktop Environment

A fully Wayland-native desktop built around [niri](https://github.com/niri-wm/niri), a scrollable-tiling compositor.

| Component | Tool |
|-----------|------|
| Window Manager | [niri](https://github.com/niri-wm/niri) |
| Status Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Terminal | [foot](https://codeberg.org/dnkl/foot) (primary), [kitty](https://github.com/kovidgoyal/kitty) |
| App Launcher | [fuzzel](https://codeberg.org/dnkl/fuzzel) |
| Notifications | [fnott](https://codeberg.org/dnkl/fnott) |
| Lock Screen | [swaylock](https://github.com/swaywm/swaylock) |
| Idle Manager | swayidle |
| Screenshots | grim + slurp + satty + wayfreeze |
| Screen Recording | wf-recorder, [OBS Studio](https://obsproject.com/) |
| Clipboard | cliphist + wl-clipboard |
| File Manager | [lf](https://github.com/gokcehan/lf) with D-Bus integration + [xdg-desktop-portal-termfilechooser](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser) |
| Browser | [qutebrowser](https://github.com/qutebrowser/qutebrowser) (keyboard-driven, vim-like) |

## Development Setup

### Development Environments

This repository's default devShell is for maintaining the NixOS configuration. It is loaded by the root `.envrc` through direnv/nix-direnv and includes Nix maintenance tools such as `nixfmt`, `statix`, `deadnix`, `shellcheck`, `shfmt`, `jq`, `git`, and `ripgrep`.

Run `nix develop` from the repository root to also prepare the `spreadconfig-nix`
and `nixos-best-practices` skills for Codex and Claude Code. The root flake uses
the same `mkWorkspace` implementation as the workspace template, with Claude
support enabled. Local skills use the checkout named by `SPREADCONFIG_SOURCE_ROOT`,
which Home Manager supplies. Start agent sessions from this repository root;
change the `repoWorkspace.skills` selection in `flake.nix` and reenter the shell
to refresh the links. Generated instructions and workspace state are ignored by Git.

Language runtimes and project-specific build tools are intentionally not installed globally here. Put them in each project's own `flake.nix`/`devShell` and load that environment with direnv.

### Independent agent workspaces

Create any directory from `templates.workspace` (also the default template), then
select skills and tools in its own flake. `nix develop`
prepares `.agents/skills` and shared instructions; optional Claude support uses the
same sources. Each skill uses its declared source; local catalog skills link the
central checkout named by `SPREADCONFIG_SOURCE_ROOT`.

See [workspace setup](docs/workspaces.md) for commands, examples, ownership rules
and checks. Home Manager provides the machine default source path and global
skills; each workspace selects its own skills in its flake.

### Editor

[nixvim](https://github.com/nix-community/nixvim) (Neovim) with VSCode-inspired theme, full LSP integration, and custom color overrides matching the system palette.

### Shell

Zsh with:
- [Starship](https://starship.rs/) prompt (custom theme-matched palette)
- zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions
- fzf with fzf-tab integration
- Custom aliases and colored output via bat

### Other Dev Tools

- **Git**: gh (GitHub CLI), diff-so-fancy, custom git-ai-commit script
- **Reverse Engineering**: jadx, ghidra
- **AI**: Claude Code
- **Java**: HMCL (Minecraft launcher)
- **IDE**: JetBrains Toolbox

## Communication

- WeChat
- QQ (patched for Wayland IME)
- Telegram Desktop + tdl
- Element

## Secrets Management

- [pass](https://www.passwordstore.org/) — Standard Unix Password Manager
- pass-secret-service — D-Bus secrets backend
- GPG agent for signing/encryption

## Custom Scripts

Sources live beside their owning application in `modules/home/<app>/scripts/`.
Each application contributes to `spreadconfig.scriptFiles`; Home Manager assembles
one link tree at `~/scripts`, preserving the runtime directories below.
Hardware-aware helpers read the generated `~/.config/spreadconfig/host.sh` for the
configured host and device paths. Nix maintenance commands live in
`modules/home/nix-tools/scripts/nix/` and are shared by all hosts:

| Directory | Contents |
|-----------|----------|
| `niri/` | Window management, screenshots, screen recording, dropdown terminals, audio control, app launching |
| `nix/` | System update (`nix_full_update`), garbage collection (`nix_clean`), generation management |
| `util/` | Battery/brightness info, audio switching, lf wrappers, git-ai-commit |
| `config/` | Zsh config, aliases, colored output, fzf preview |
| `sway/` | Sway helpers |
| `legacy/` | Additional shell utilities |

See [application layout](docs/application-layout.md) for source ownership,
editable links, host fragments, and validation commands.

The standalone `flake-input-watcher` checks direct flake inputs on every host,
by default five minutes after graphical login and then every six hours. Its
systemd user timer runs the Bash program, which sends combined fnott
notifications and supports reusable per-input hooks. See
[flake input watcher](docs/flake-input-watcher.md) for scheduling, input switches,
hook bindings, and manual checks. It does not update the lock file or rebuild.

The independent notification history and shared fzf selector follow the same
external-package model. See [independent applications](docs/independent-apps.md)
for repository ownership and terminal/window manager integration.

## Theme System

All applications share a single dark color palette defined in `modules/home/vars.nix`. Colors are injected into every config via Nix module arguments — no duplicated hex values.

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#000000` | Base background |
| Transparent | `#00000000` | Transparent overlays |
| Mocha BG | `#0e1117` | Catppuccin-inspired secondary bg |
| White | `#d4d4d4` | Default text |
| Red | `#bc3f3c` | Errors, critical |
| Green | `#6a9955` | Success, comments |
| Yellow | `#e6e6aa` | Warnings, functions |
| Blue | `#47a2ed` | Keywords, primary accent |
| Purple | `#3181a7` | Secondary accent |
| Cyan | `#47ccb1` | Classes, info |
| Bright Dark | `#72737a` | Dimmed text |
| Bright Red | `#ff0000` | Bright errors |
| Bright Blue | `#8cd7ff` | Bright highlights |
| Bright White | `#ffffff` | Emphasis text |
| Bright Yellow | `#ffc66d` | Bright warnings |

### Font Stack

All Noto family with CJK fallback chain:

- **Sans**: Noto Sans → Noto Sans CJK SC/HK/TC/JP/KR → Noto Color Emoji
- **Mono**: Noto Sans Mono → Noto Sans Mono CJK SC/HK/TC/JP/KR → Symbols Nerd Font Mono → Emoji
- **Serif**: Noto Serif → Noto Serif CJK SC/HK/TC/JP/KR → Emoji

Font size is 16pt across the desktop (GTK, Qt, terminal), with larger sizes for lock screen (30pt) and launcher (18pt).

### Themed Applications

Every application below uses colors from the central palette:

foot, fuzzel, fnott, swaylock, waybar, niri, nixvim, qutebrowser, starship, btop, bat, mpv, zathura, lazygit, zsh-syntax-highlighting, fcitx5, obsidian, wayprompt, gdu

## Post-Install Setup

### Secrets

Place the following files in `./secrets/` (sourced from `pass`):

| File | Source | Description |
|------|--------|-------------|
| `gh_token` | `pass show github/token` | GitHub CLI token, read during Home Manager activation |
| `passwd_hash` | `mkpasswd -m yescrypt` | Hashed login password for `users.users.spreadzhao.hashedPasswordFile` |
| `qutebrowser_quickmarks` | manual | Qutebrowser quickmarks (can be empty) |

### Repository Location

The config references this repo at an absolute path. Clone to:

```bash
~/workspaces/spreadconfig
```

Alternatively, create a symlink:

```bash
sudo ln -s /path/to/spreadconfig /etc/nixos
```

### fcitx5

Input method framework is enabled but UI/theme configuration must be done manually through fcitx5's own settings after first login.

## Shared GitHub authentication

All hosts use the same `github-token` in `secrets/secrets.yaml`. SOPS renders a protected
`/run/secrets-rendered/gh-hosts.yml` at activation time; Home Manager links
`~/.config/gh/hosts.yml` to it. The standard `programs.gh` package and its HTTPS Git
credential helper read this file. No wrapper or shell token export is needed.
SSH Git remotes still use SSH keys. Only placeholders, not tokens, enter the Nix store.
The rendered file is owned by `spreadzhao:users`, mode `0400`.

### First switch from the previous setup

If `~/.config/gh/hosts.yml` is still a regular file, remove that old local copy before
switching (the shared SOPS token remains intact). Home Manager will create the link:

```bash
if [ -f ~/.config/gh/hosts.yml ] && [ ! -L ~/.config/gh/hosts.yml ]; then
  rm ~/.config/gh/hosts.yml
fi
unset GH_TOKEN GITHUB_TOKEN GH_CONFIG_DIR
sudo nixos-rebuild switch --flake .#desktop1
gh auth status
```

Use the corresponding host name on other machines. Remove any persistent token exports
from shell/session configuration too: environment tokens override the generated file.
A nonempty token in this file takes precedence over old keyring credentials. Keep
`github-token` valid and nonempty; an empty value can fall back to an old keyring login.

### Replace the shared token

Edit the existing `github-token` value; do not create one token per machine:

```bash
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops edit secrets/secrets.yaml
```

Sync the updated ciphertext and rebuild each host, then run `gh auth status`.
No `gh auth login` is needed for normal use. The managed `hosts.yml` is read-only:
do not use `gh auth login`, `logout`, `switch`, or `refresh` to change this managed login.

If obtaining a new token via browser login, use a separate, temporary config directory
and the standard CLI so the managed file is not modified (run in one terminal):

```bash
gh_setup_dir=$(mktemp -d)
nix shell --inputs-from . nixpkgs#gh -c env -u GH_TOKEN -u GITHUB_TOKEN GH_CONFIG_DIR="$gh_setup_dir" gh auth login --hostname github.com --git-protocol https --web --insecure-storage
nix shell --inputs-from . nixpkgs#gh -c env -u GH_TOKEN -u GITHUB_TOKEN GH_CONFIG_DIR="$gh_setup_dir" gh auth token --hostname github.com
```

The token is stored temporarily in that private directory and displayed locally. Paste it
into SOPS, not into chat or Git. After saving it successfully, delete the temporary directory
with `rm -rf -- "$gh_setup_dir"` and `unset gh_setup_dir`. Perform browser authorization only
once and distribute that token through SOPS. Revoking old tokens interrupts their access
until the replacement is deployed.

A new machine needs shared-key initialization (`./scripts/sops-key init`) before rebuilding.
For a private configuration repository, bootstrap by securely copying the checkout or
temporarily using the same token.

## Chromium bookmarks

Qutebrowser and Chromium share the existing quickmarks source at
`~/.password-store/qutebrowser/qutebrowser_quickmarks`, outside this repository.
Qutebrowser reads and writes it directly through the existing symlink; the `m`
and `M` bindings continue to save quickmarks. NixOS activation (including
`nixos-rebuild switch` and boot) converts it once into Chromium's managed bookmark
policy at `/etc/chromium/policies/managed/qutebrowser-bookmarks.json`.

Only the conversion code and file paths are managed by Nix. Evaluation and builds
do not read the bookmark data, so new build outputs contain no bookmark contents.
There is no synchronization service, watcher, timer, or custom wrapper package.
Chromium receives changes at the next activation; `nixos-rebuild build` alone
does not refresh bookmarks. If the source is missing, activation succeeds without
creating the source file or its parent directories. If conversion fails, activation
warns and retains the previous policy. An existing empty source clears Chromium's
managed bookmarks. The converter never changes the source contents or permissions.

For a new machine, bootstrap in this order:

1. Initialize SOPS with `./scripts/sops-key init` (or `--root /mnt` during
   installation), using the encrypted identity in this configuration repository.
2. Apply NixOS to provision the gh credentials. Chromium bookmark generation is
   skipped while the private quickmarks file is absent.
3. Clone your private repository into `~/.password-store`.
4. Run `switch` again to generate Chromium's managed bookmarks.

After saving a quickmark in qutebrowser, let it save normally, or run
`:save quickmark-manager` before switching to include the latest changes.
Chromium's managed bookmarks are read-only; edit the shared collection in
qutebrowser. Use the private repository's normal push/pull workflow between
machines. Activation does not clone or synchronize the repository.

## Claude Code with GLM

Claude Code uses the [GLM Coding Plan Anthropic endpoint](https://docs.bigmodel.cn/cn/coding-plan/tool/claude).
The default model and the Opus, Sonnet, and Haiku aliases all select `glm-5.3`.
The configuration disables 1M context and does not use the `[1m]` suffix.

The shared `glm-api-key` is encrypted in `secrets/secrets.yaml`, alongside the
GitHub and TextBridge tokens. To replace it:

```bash
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops edit secrets/secrets.yaml
```

Model and endpoint settings live in the `claude-settings.json` SOPS template in
`modules/nixos/secrets.nix`. Only the API key is encrypted; the template uses a
placeholder, like `gh-hosts.yml`. SOPS fills it at runtime, and Home Manager links
`~/.claude/settings.json` to the rendered file, owned by `spreadzhao:users` with
mode `0400`. The key never enters the Nix store in plaintext.

Rebuild the target host after changing the key or template. The generated settings
are read-only; make persistent changes in Nix or SOPS. Claude Code manages its own
onboarding and mutable state in `~/.claude.json`; activation does not modify it.
Restart Claude Code after activation and use `/status` to check the active model.

## Rebuilding

```bash
# Full rebuild & switch
sudo nixos-rebuild switch --flake ~/workspaces/spreadconfig#desktop1
sudo nixos-rebuild switch --flake ~/workspaces/spreadconfig#thinkbook
sudo nixos-rebuild switch --flake ~/workspaces/spreadconfig#zephyrus-m16

# Or use the helper script
~/scripts/nix/nix_full_update
```
