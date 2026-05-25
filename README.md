# My NixOS Config

My personal NixOS configuration, built with [flakes](https://wiki.nixos.org/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). Designed for a terminal-centric, Wayland-first developer workflow with a unified dark color scheme across every application.

<img width="1920" height="1080" alt="Screenshot_DP-2_20260227_000645" src="https://github.com/user-attachments/assets/fddcf456-6f25-4798-89ab-ee930262a981" />

## Repository Structure

```
.
├── flake.nix                          # Flake entry point
├── hosts/
│   ├── thinkbook/                     # AMD laptop host config
│   │   ├── configuration.nix          # Imports generated hardware and host-only system modules
│   │   ├── hardware-configuration.nix # nixos-generate-config hardware facts
│   │   ├── home.nix                   # Host-only Home Manager module entry
│   │   ├── home/profile.nix           # Host Home Manager profile values
│   │   └── nixos/                     # Host-only NixOS modules
│   │       ├── identity.nix           # Hostname and identity
│   │       ├── hardware.nix           # CPU/GPU/hardware policy
│   │       ├── profile.nix            # Host NixOS profile values
│   │       └── services.nix           # Host-only services such as LACT/TLP
│   └── zephyrus-m16/                  # ASUS ROG host config
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       ├── home.nix
│       ├── home/profile.nix
│       └── nixos/
│           ├── identity.nix
│           ├── hardware.nix           # nixos-hardware, Intel/NVIDIA PRIME
│           ├── profile.nix
│           ├── services.nix           # ROG service entry point
│           └── services/asusd.nix     # asusd/supergfxd declarative config
├── modules/
│   ├── nixos/                         # Shared system-level NixOS modules
│   │   ├── boot.nix
│   │   ├── greetd.nix
│   │   ├── pipewire.nix
│   │   └── zsh.nix
│   └── home/                          # Shared Home Manager modules
│       ├── vars.nix                   # Centralized theme colors, fonts, paths, host helpers
│       ├── home-core.nix              # Home session variables
│       ├── nixvim.nix                 # Neovim via nixvim
│       ├── niri.nix                   # Shared program module with host-specific external config
│       ├── waybar.nix
│       ├── fnott.nix
│       └── zsh.nix
├── spreadconfig/
│   ├── config/<host>/                 # Host-specific application config files
│   └── scripts/<host>/                # Host-specific shell scripts
│       ├── niri/                      # Niri WM scripts (screenshots, audio, etc.)
│       ├── sway/                      # Legacy Sway scripts
│       ├── nix/                       # Nix maintenance scripts
│       ├── util/                      # Utility scripts (audio, lf wrappers, git-ai-commit)
│       ├── config/                    # Zsh config, aliases, color output
│       ├── legacy/                    # Retired scripts
│       └── test/                      # Test scripts
└── secrets/                           # Secret files (pass-managed, not in git)
```

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | NixOS unstable (primary package set) |
| `nixpkgs-old-dd9b079` | Pinned nixpkgs for compatibility |
| `nixpkgs-old-a6c3b1b` | Pinned nixpkgs for compatibility |
| `home-manager` | User environment management |
| `nixos-hardware` | Hardware presets for supported laptops |
| `nixvim` | Declarative Neovim configuration |

## Hosts

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

Language runtimes and project-specific build tools are intentionally not installed globally here. Put them in each project's own `flake.nix`/`devShell` and load that environment with direnv.

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
- **AI**: Claude Code, Ollama (local LLM)
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

Located in `spreadconfig/scripts/<host>/`:

| Directory | Contents |
|-----------|----------|
| `niri/` | Window management, screenshots, screen recording, dropdown terminals, audio control, app launching |
| `nix/` | System update (`nix_full_update`), garbage collection (`nix_clean`), generation management |
| `util/` | Battery/brightness info, audio switching, lf wrappers, git-ai-commit |
| `config/` | Zsh config, aliases, colored output, fzf preview |
| `sway/` | Legacy Sway scripts (retained for reference) |
| `legacy/` | Retired scripts (moved, not deleted) |

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

## Rebuilding

```bash
# Full rebuild & switch
sudo nixos-rebuild switch --flake ~/workspaces/spreadconfig#thinkbook
sudo nixos-rebuild switch --flake ~/workspaces/spreadconfig#zephyrus-m16

# Or use the helper script
~/scripts/nix/nix_full_update
```
