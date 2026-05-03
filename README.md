# My NixOS Config

My personal NixOS configuration, built with [flakes](https://wiki.nixos.org/wiki/Flakes) and [home-manager](https://github.com/nix-community/home-manager). Designed for a terminal-centric, Wayland-first developer workflow with a unified dark color scheme across every application.

<img width="1920" height="1080" alt="Screenshot_DP-2_20260227_000645" src="https://github.com/user-attachments/assets/fddcf456-6f25-4798-89ab-ee930262a981" />

## Repository Structure

```
.
├── flake.nix                          # Flake entry point
├── host/
│   └── thinkbook/                     # Thinkbook laptop host config
│       ├── configuration.nix          # System config (imports nixos/modules)
│       ├── hardware-configuration.nix # Auto-generated hardware config
│       └── home.nix                   # Home-manager config (imports home/modules)
├── nixos/modules/                     # System-level NixOS modules
│   ├── apps.nix                       # System packages
│   ├── boot.nix                       # systemd-boot, v4l2loopback
│   ├── environment.nix                # Environment variables & paths
│   ├── filesystems.nix                # Mount points
│   ├── fonts.nix                      # System font packages
│   ├── hardware.nix                   # Bluetooth
│   ├── networking.nix                 # Network, firewall, DNS
│   ├── nix.nix                        # Nix daemon settings
│   ├── security.nix                   # Polkit, sudo
│   ├── state-version.nix              # system.stateVersion
│   ├── systemd.nix                    # systemd services & timers
│   ├── time-console.nix               # Time zone, locale, console
│   ├── users.nix                      # User accounts
│   ├── programs/                      # System-level programs
│   │   ├── dconf.nix
│   │   ├── nano.nix
│   │   ├── nh.nix
│   │   ├── nix-ld.nix
│   │   ├── vim.nix
│   │   └── zsh.nix
│   └── services/                      # System-level services
│       ├── davfs2.nix
│       ├── greetd.nix                 # Login manager (agreety → niri)
│       ├── gvfs.nix
│       ├── lact.nix                   # AMD GPU control
│       ├── libinput.nix
│       ├── openssh.nix
│       ├── pipewire.nix               # Audio/video
│       ├── udisks2.nix
│       ├── upower.nix
│       └── xdg-autostart.nix
├── home/modules/                      # User-level home-manager modules
│   ├── vars.nix                       # Centralized theme colors, fonts, paths
│   ├── apps.nix                       # User packages
│   ├── dconf.nix                      # GNOME/dconf settings
│   ├── fonts.nix                      # Fontconfig
│   ├── gtk.nix                        # GTK theme
│   ├── qt.nix                         # Qt theme
│   ├── home-core.nix                  # Home session variables
│   ├── i18n.nix                       # Input method (fcitx5)
│   ├── nixvim.nix                     # Neovim via nixvim
│   ├── xdg.nix                        # XDG user dirs & MIME
│   ├── systemd.nix                    # User systemd services
│   ├── programs/                      # Program configurations
│   │   ├── bat.nix
│   │   ├── btop.nix
│   │   ├── codex.nix
│   │   ├── fd.nix
│   │   ├── feh.nix
│   │   ├── file-manager-dbus.nix
│   │   ├── foot.nix
│   │   ├── fuzzel.nix
│   │   ├── fzf.nix
│   │   ├── gdu.nix
│   │   ├── gh.nix
│   │   ├── git.nix
│   │   ├── gpg.nix
│   │   ├── java.nix
│   │   ├── kitty.nix
│   │   ├── lazygit.nix
│   │   ├── lf.nix
│   │   ├── niri.nix
│   │   ├── npm.nix
│   │   ├── obs-studio.nix
│   │   ├── opencode.nix
│   │   ├── qutebrowser.nix
│   │   ├── satty.nix
│   │   ├── starship.nix
│   │   ├── swaylock.nix
│   │   ├── waybar.nix
│   │   ├── wayprompt.nix
│   │   ├── xdg-desktop-portal-termfilechooser.nix
│   │   ├── zathura.nix
│   │   ├── zoxide.nix
│   │   └── zsh.nix
│   └── services/                      # User services
│       ├── cliphist.nix
│       ├── fnott.nix
│       ├── gpg-agent.nix
│       ├── ollama.nix
│       ├── pass-secret-service.nix
│       └── swayidle.nix
├── packages/
│   └── file-manager-dbus/             # Custom D-Bus file manager service
├── spreadconfig/
│   ├── config/                        # Application config files (dotfiles)
│   └── scripts/                       # Shell scripts
│       ├── niri/                      # Niri WM scripts (screenshots, audio, etc.)
│       ├── sway/                      # Legacy Sway scripts
│       ├── nix/                       # Nix maintenance scripts
│       ├── util/                      # Utility scripts (wallpaper, audio, git-ai-commit)
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
| `nixvim` | Declarative Neovim configuration |
| `file-manager-dbus` | Custom D-Bus file manager service |

## Hosts

### thinkbook

My primary laptop — AMD CPU/GPU with a Wayland-native desktop stack.

- **Boot**: systemd-boot with v4l2loopback (OBS virtual camera)
- **Login**: greetd with agreety, auto-starts niri
- **Audio**: PipeWire
- **GPU**: AMD with OpenCL support, managed via LACT

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
| Wallpaper | wbg |
| Clipboard | cliphist + wl-clipboard |
| File Manager | [lf](https://github.com/gokcehan/lf) with D-Bus integration + [xdg-desktop-portal-termfilechooser](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser) |
| Browser | [qutebrowser](https://github.com/qutebrowser/qutebrowser) (keyboard-driven, vim-like) |

## Development Setup

### Languages & Toolchains

| Language | Compiler/Tools |
|----------|---------------|
| C/C++ | gcc, clang (hiPrio), lldb, gdb, cmake, ninja |
| Rust | rustc, cargo, rust-analyzer, rustfmt |
| Go | go, gopls |
| Python | python3 |
| Java | JDK 25 (default), 21, 17, 11, 8 |
| Bash | bash-language-server, shfmt |
| Lua | lua-language-server, stylua |
| Nix | nixd, nixfmt, nixfmt-tree |

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

Located in `spreadconfig/scripts/`:

| Directory | Contents |
|-----------|----------|
| `niri/` | Window management, screenshots, screen recording, dropdown terminals, audio control, app launching |
| `nix/` | System update (`nix_full_update`), garbage collection (`nix_clean`), generation management |
| `util/` | Wallpaper rotation, battery/brightness info, audio switching, lf wrappers, git-ai-commit |
| `config/` | Zsh config, aliases, colored output, fzf preview |
| `sway/` | Legacy Sway scripts (retained for reference) |
| `legacy/` | Retired scripts (moved, not deleted) |

## Theme System

All applications share a single dark color palette defined in `home/modules/vars.nix`. Colors are injected into every config via Nix module arguments — no duplicated hex values.

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
| `gh_token` | `pass show github/token` | GitHub CLI token |
| `passwd` | `pass show sudo` | Login password |
| `qutebrowser_quickmarks` | manual | Qutebrowser quickmarks (can be empty) |
| `volcengine_api_key` | [Volcengine console](https://console.volcengine.com/ark) | API key |

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

# Or use the helper script
~/scripts/nix/nix_full_update
```
