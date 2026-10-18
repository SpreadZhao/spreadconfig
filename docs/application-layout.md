# Configuration layout

Shared system modules live in `modules/nixos`; shared user modules live in
`modules/home`. Home Manager imports top-level `.nix` files and direct child
`default.nix` files. Keep package-only modules as single files, and use an
application directory when it has native files or scripts. Do not create both
`<app>.nix` and `<app>/default.nix`.

## Ownership

Each application owns its configuration, packages, session variables, script
PATH entries, MIME associations, desktop entries and user services. Portal
implementations own their backend registrations. System services belong in
NixOS; for example, `psst.nix` supplies the user Polkit agent while
`modules/nixos/polkit.nix` enables authorization.

`home-core.nix` holds user identity and session defaults. `xdg.nix` holds XDG
infrastructure, directory conventions and desktop-wide MIME fallback order.
`vars.nix` provides shared colors, fonts, paths and file helpers. Keep shell
aliases in the shell module.

Preserve ordering where it affects behavior. Script PATH groups use priorities
100 for Niri, 200 for shared tools and 300 for Nix tools, followed by the default
`.local/bin` entry. `xdg-drawio.nix` preserves Draw.io's MIME package position in
`home.packages`, which also affects Fontconfig directory order.

## Host configuration

`hosts/<name>/host.nix` declares the system, form factor, CPU, GPUs, capabilities,
profiles and module lists. `lib/host-context.nix` validates these before module
evaluation and passes the same `host` value to NixOS and Home Manager. The
constructor is exported as `lib.mkHost` in the flake outputs.

Shared modules read `host.profile.nixos`, `host.profile.home` and predicates
such as `host.gpu.hasNvidia`. CPU and GPU vendors are independent; hybrid systems
can have several GPU predicates. Unknown capabilities are `null`.

Put application defaults in their own modules and overrides in host application
modules, using standard NixOS or Home Manager options. Profiles hold shared
policy such as font scaling and device paths. Host leaf modules hold drivers,
PCI addresses, fan curves and hardware-specific services.

Native defaults live at `modules/home/<app>/files/`; host replacements use the
same relative path under `hosts/<host>/home/<app>/files/`. Scripts follow the
same rule under `scripts/`. A host file takes precedence. Directory mappings
keep other shared files and include host-only additions. Missing required shared
files and conflicting file/directory paths are errors.

Current examples:

- Niri loads `files/host.kdl` before shared rules. Hosts supply input and display
  settings; the shared fallback is empty. Preserve rule and output order.
- Qutebrowser loads `files/host.py` after shared settings and before the theme.
  Zephyrus also selects its Intel Vulkan package in its Home Manager module.
- Psst uses `services.gpg-agent.pinentry.package`. Zephyrus sets
  `ZED_DEVICE_ID=46a6` on the gpg-agent and Psst Polkit services to select Intel.
  Directly running the Psst binaries does not force a GPU.
- Waybar host modules call the shared JSON/CSS constructor with their dimensions
  and temperature path. Battery layout follows the declared capability.

Keep qutebrowser's `autoconfig.yml` application-managed and its quickmarks linked
to Password Store. Do not replace the entire configuration directory.

## Package configuration

Use application settings, desktop entries and service environments before
adding package wrappers. QQ and scrcpy supply desktop entries with the upstream
IDs. Qutebrowser installs a higher-priority desktop file in the user profile,
preserving upstream translations and actions.

Application-specific session variables belong in the owning module. Set user
systemd variables when services also need them. Log out and back in after
changing session variables.

Keep generic graphics variables local to the application or service. Btop uses
the package's `cudaSupport` option on NVIDIA hosts. Qutebrowser's Intel Vulkan
wrapper, Codex's profile and compatibility fixes, and JetBrains' plugin and
toolchain integration have separate runtime requirements and remain in place.

## Editable files and scripts

`lib/mutable-files.nix` provides these helpers:

| Helper | Result |
| --- | --- |
| `repoLink path` | A checked link to a regular file in the editable checkout |
| `repoEntries directory` | A target/source map for a repository directory |
| `repoTree name entries` | A store directory of links with validated target paths |
| `appSource app path` | The selected host or shared repository-relative file path |
| `appEntries app directory` | Merged shared and host directory mappings |

Validation uses `repoRoot`; runtime links use `projDir`. Existing file edits
appear on application reload. Adding or removing files, or changing generated
settings, needs a build and activation. Rolling back a generation does not undo
edits in the checkout.

Applications register `appEntries "<app>" "scripts"` with
`spreadconfig.scriptFiles`. Home Manager assembles the maps into `~/scripts`;
conflicting contributions from separate applications are errors. Keep installed
names, executable modes and PATH order stable.

Scripts needing host or checkout data source
`script-tools/scripts/config/host_context.sh`. It finds a parent containing
`flake.nix` and `hosts/`, sets `SPREADCONFIG_SOURCE_ROOT`, and loads
`${XDG_CONFIG_HOME:-$HOME/.config}/spreadconfig/host.sh`. Resolve installed
symlinks before finding the source; do not assume a fixed directory depth.
`SPREADCONFIG_HOST` selects another host for maintenance commands. Shared
`sns` and `sns_until` belong in nix-tools, not individual host directories.

## Add a host

The flake discovers directories containing `host.nix`. Create
`hosts/my-laptop/{home,nixos}` and use this Intel integrated-GPU example as a
starting point for `host.nix`:

```nix
{
  system = "x86_64-linux";
  formFactor = "laptop";
  cpu.vendor = "intel";
  gpu.devices = [
    { vendor = "intel"; kind = "integrated"; }
  ];
  capabilities = {
    battery = true;
    backlight = true;
    bluetooth = null;
  };
  profile = {
    nixos = import ./nixos/profile.nix;
    home = import ./home/profile.nix;
  };
  modules = {
    nixos = [ ./configuration.nix ];
    home = [ ./home.nix ];
  };
}
```

Create `configuration.nix`:

```nix
{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = host.name;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
```

Start `home.nix` with `{ ... }: { }`, then explicitly import any host application
modules. Start `home/profile.nix` with `{ }` and `nixos/profile.nix` with
`{ proxy.enable = false; }` if no proxy is ready. Add
`home/niri/files/host.kdl` when display or input settings are needed.

Generate `hardware-configuration.nix` on the target machine as described in
[installation](install.md#clone-and-select-the-host). Hardware declarations do
not configure every driver: add NVIDIA options and PRIME addresses only when
they match the actual devices.

## Validate changes

Use path flakes while files are untracked. Compare against the working tree
before the change, including existing edits, and check ordered packages, MIME
precedence, service dependencies and generated file contents when refactoring.

```sh
nixfmt path/to/changed-file.nix
git diff --check
nix eval --raw --no-write-lock-file \
  "path:$PWD#nixosConfigurations.desktop1.config.home-manager.users.spreadzhao.home.activationPackage.drvPath"
nix eval --raw --no-write-lock-file \
  "path:$PWD#nixosConfigurations.desktop1.config.system.build.toplevel.drvPath"
```

Repeat for affected hosts. For shared changes, check all three. Build affected
asset trees without activating them, inspect paths and modes, and validate Niri
trees with `niri validate -c <built-tree>/config.kdl`. Check changed shell scripts
with their parser and ShellCheck. Run switches manually after reviewing results.
