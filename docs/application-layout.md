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
200 for shared tools and 300 for Nix tools, followed by the default `.local/bin`
entry.

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

- The dwl Home Manager module in `spreadless` exposes compile-time macros through
  `wayland.windowManager.dwl.settings`. Each host supplies
  `spreadconfig.dwl.startupCommands` in `home/dwl.nix` to apply its display layout
  once at startup. Zephyrus sets `SDWL_TABLET_RULES` in `home/gaomon-tablet.nix`.
- Qutebrowser loads `files/host.py` after shared settings and before the theme.
  Zephyrus also selects its Intel Vulkan package in its Home Manager module.
- Psst uses `services.gpg-agent.pinentry.package`. Zephyrus sets
  `ZED_DEVICE_ID=46a6` on the gpg-agent and Psst Polkit services to select Intel.
  Directly running the Psst binaries does not force a GPU.

Keep qutebrowser's `autoconfig.yml` application-managed and its quickmarks linked
to Password Store. Do not replace the entire configuration directory.

## dwl session

`modules/nixos/dwl.nix` sets `XDG_CURRENT_DESKTOP`, `XDG_SESSION_TYPE` and
`XDG_SESSION_DESKTOP` in greetd's environment before dwl starts.
The `dwl-session` launcher loads Home Manager's session variables and feeds
`slstatus -s` into dwl. Its startup hook imports the session environment,
including `PATH` and `SCRIPT_HOME`, into systemd and D-Bus, then starts
`dwl-session.target` and runs the host's display commands once. Systemd orders
`dwl-session.target` before `graphical-session.target` and
`xdg-desktop-autostart.target`. A missing connector does not prevent the session
from starting. Exiting dwl stops slstatus and the graphical session targets.

`modules/home/slstatus.nix` imports the slstatus Home Manager module from
`spreadless` and sets `programs.slstatus.interval` to 9000 milliseconds. The
components show CPU and memory usage, CPU temperature, network interface type,
default audio output and input volume, battery charge when the host declares a
battery, and `HH:MM` time, in that order. Values precede Nerd Font icons,
without percent signs or separators between components. Audio icons identify
the device type and mute state. Battery icons indicate charge level and
distinguish charging, discharging, full and not charging.

Native C components read the CPU temperature and default route; audio queries
use `wpctl` through `run_command`. Network icons identify Wi-Fi and other
default-route interfaces, or show a disconnected icon when no interface is
found. The first CPU sample is `-` until the next interval. The bar shows the
same status text on every output.

The status formats use barcolors markup and the shared palette in
`modules/home/vars.nix`.
CPU is bright yellow, memory uses `theme_purple`, network is red, audio is blue,
and temperature and time are green. Temperature turns yellow at 60°C and
red at 80°C. The bar uses Noto Sans at Fontconfig `size=14`, with Chinese,
Nerd Font symbols and emoji fallbacks at the same size. Tags, layout and title
text have 2 logical pixels of padding on each side; the status has 2 at its right
edge.

`wayland.windowManager.dwl.settings` supplies `SDWL_*` macros through one generated
`host.h`. Strings are quoted, booleans become `0` or `1`, and `{ raw = "..."; }`
supplies a single-line C expression or initializer list. The module's read-only
`finalPackage` is the configured package. Display commands live in the host's
Nix module. `SDWL_FONT` selects the primary font, `SDWL_FONT_FALLBACKS` supplies
the fallback list, and `SDWL_BAR_HPAD` and `SDWL_STATUS_RPAD` set the padding.

`start_floating_foot.sh` belongs to Foot and is installed under `~/scripts/util`.
It accepts one shell-command string and opens a `lick-foot` window. Qutebrowser
and the zsh `ff` alias use it. `fzf-popup-foot` separately forwards an argument
vector and the caller's environment through Foot's server. Both use the same
floating window rule.

The shared `screenshot.sh` and `image_action_menu.sh` scripts live in
`modules/home/script-tools/scripts/util`. Grim, slurp, lswt and Tesseract are
installed by their own application modules. `Super+Shift+A` freezes the screen
and selects a region; `Super+Ctrl+Shift+A` selects an output.
`~/scripts/util/screenshot.sh -w` selects a window from a list for capture.
All modes open the shared image action menu for clipboard copy, saving,
Satty editing, a floating image viewer, or Chinese/English OCR. The menu saves
images in `screenshot/` under the XDG Pictures directory. Satty is configured
through `programs.satty` and saves in the `satty/` subdirectory.

`Super+Shift+V` opens clipboard history in fzf-popup with file previews. Text
entries are copied unchanged; image entries open the shared image action menu.
Home Manager starts text and image clipboard watchers with the graphical
session. `Super+Z` launches shmooz for screen zoom, spotlight and annotation.

`modules/home/i18n.nix` disables Fcitx preedit by default. `Ctrl+Alt+P`
toggles preedit during the session.

Swayidle turns displays off after 600 seconds and locks after 605 seconds.
Its resume command turns displays back on when input resumes. The Lock Policy
menu pauses swayidle by replacing its command with `sleep infinity` and restores
it by removing that service override.

Run `swaylock` to lock without turning displays off. The dwl lock shortcut runs
`dwl_lock.sh`: it waits for `swaylock -f` to establish the lock, then runs
`dpms-off`. Running `dpms-off` alone turns displays off without locking. It waits
for input to turn displays back on, then exits. These manual actions also work
while automatic locking is paused.

Tablet rules match the exact input device name and select an output connector.
The full tablet area maps to that output. With no rule, or while the named output
is absent from the layout, the tablet maps to the whole layout. The compositor
forwards pen pressure and tilt through tablet-v2 and emulates a pointer for
clients without tablet support. GAOMON pad shortcuts remain in input-remapper.

## Package configuration

Use application settings, desktop entries and service environments before
adding package wrappers. QQ and scrcpy supply desktop entries with the upstream
IDs. Qutebrowser installs a higher-priority desktop file in the user profile,
preserving upstream translations and actions.

Application-specific session variables belong in the owning module. Set user
systemd variables when services also need them. Log out and back in after
changing session variables.

Codex uses one shared package with separate GUI and CLI launchers for each
account. The launchers isolate `CODEX_HOME`, SQLite state, and Electron user
data while preserving the desktop session's XDG directories for external tools.
Runtime caches and desktop logs use upstream defaults. Browser helpers use the
upstream `browser-proxy` feature. Desktop cloud WebSockets use a local SOCKS
proxy patch in `codex/patches/`. GitHub CLI reads the shared login through the
normal XDG path.

Codex build scripts live in `codex/scripts/build/`. Nix supplies package paths,
profile settings and environment variables. The CLI wrapper sources
`codex/scripts/runtime/cli-environment.sh` to put the profile's private bin
directory first on `PATH` and pass that `PATH` to spawned shells.

Keep generic graphics variables local to the application or service. Btop uses
the package's `cudaSupport` option on NVIDIA hosts.

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
`home/dwl.nix` for display startup commands and import it from `home.nix`. Keep
tablet mappings in the host's tablet module.

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
asset trees without activating them and inspect paths and modes. Check changed
shell scripts with their parser and ShellCheck. Run switches manually after
reviewing results.
