# spreadconfig

Personal NixOS and Home Manager configuration for three machines. The desktop
uses niri, Waybar, Foot, fuzzel and fnott, with shared dark colors and Noto fonts.

<img width="1920" height="1080" alt="niri desktop with the shared dark theme" src="https://github.com/user-attachments/assets/fddcf456-6f25-4798-89ab-ee930262a981" />

## Install

Follow the [installation guide](docs/install.md) for USB preparation, networking,
disk setup and the first boot. Initialize SOPS before installing NixOS, then
restore Password Store and its GPG identity after login.

Keep this checkout at `~/workspaces/spreadconfig`: application configuration and
scripts link to its editable files. Password Store lives at `~/.password-store`.
Packages and skills are fetched through flake inputs; they need no local clones.

| Host | Hardware and host-specific configuration |
| --- | --- |
| `desktop1` | Intel i5-10400F, GTX 1650; pinned graphics stack |
| `thinkbook` | AMD CPU and integrated GPU; LACT and TLP |
| `zephyrus-m16` | ASUS GU603H, Intel/NVIDIA hybrid graphics; PRIME offload, asusd, supergfxd and TLP |

A different machine needs its own [host declaration](docs/application-layout.md#add-a-host)
and generated disk configuration.

## Build and apply

Run from the checkout. Select the host explicitly if its name differs from the
current hostname. `path:` includes new files before Git tracks them.

```sh
cd ~/workspaces/spreadconfig
target_host=$(hostname -s)
test -f "hosts/$target_host/host.nix"
sudo nixos-rebuild build --flake "path:$PWD#$target_host"
```

After reviewing the build, run activation manually:

```sh
sudo nixos-rebuild switch --flake "path:$PWD#$target_host"
```

To update inputs and prepare the next boot:

```sh
~/scripts/nix/nix_update boot
```

`sns`, `sns_until` and `nix_clean` default to `switch`; `nix_update` and
`nix_full_update` default to `boot`. Agents must never execute a switch, including
through wrapper defaults. Use evaluation or `build` for checks; the user performs
every switch.

## Configuration layout

| Path | Purpose |
| --- | --- |
| `flake.nix`, `flake.lock` | Inputs, host discovery and development shell |
| `lib/host-context.nix` | Hardware facts and shared policy defaults |
| `lib/mutable-files.nix` | Checked links to editable configuration files |
| `hosts/<host>/host.nix` | Hardware declaration, profiles and module lists |
| `hosts/<host>/{home,nixos}/` | Host-specific application settings and system services |
| `modules/home/` | Shared user packages, application configuration and scripts |
| `modules/nixos/` | Shared system configuration |
| `scripts/sops-key`, `secrets/` | Identity bootstrap and encrypted credentials |

[Application layout](docs/application-layout.md) describes file overrides,
script ownership, host setup and validation. Edit shared colors and font defaults
in `modules/home/vars.nix`; host profiles can scale or override font sizes.
Native themes may also define application-specific colors.

## Development tools

`nix develop` loads the maintenance shell with nixfmt, Statix, deadnix, ShellCheck,
shfmt, Git, jq and ripgrep. The root `.envrc` loads it through nix-direnv.

NAW supplies the `spreadconfig-nix` and `nixos-best-practices` workspace skills
and generates the ignored agent instructions from `repoWorkspace.instructions`
in `flake.nix`. Edit skill content in its source repository. Home Manager manages
the global Draw.io skill separately in `modules/home/naw-global-skills.nix`.

Each software project supplies its own language toolchain through a devShell.
[Nixvim](modules/home/nixvim/README.md) uses that environment for Go, Rust, C/C++
and Python. [JetBrains IDEs](modules/home/jetbrains/README.md) have private JDK,
Android SDK and C/C++ tools scoped to their launchers.

## Credentials and integrations

- [SOPS](docs/sops.md): shared age identity, GitHub authentication and Claude Code's GLM settings.
- [Password Store](docs/password-store.md): GPG recovery, Secret Service and shared browser bookmarks.
- [Independent applications](docs/independent-apps.md): flake update notifications, notification history and fzf popups.

Fcitx5 preferences, proxy subscriptions and application logins are configured
through their applications after the first boot.
