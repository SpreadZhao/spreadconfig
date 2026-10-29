# Independent applications

[SpreadZhao/nix-packages](https://github.com/SpreadZhao/nix-packages) maintains
custom packaging for third-party applications. The applications listed below
have their own repositories. Spreadconfig consumes their locked packages and
modules and supplies desktop integration.

| Input | Upstream | Local integration |
| --- | --- | --- |
| `flake-input-watcher` | [Repository](https://github.com/SpreadZhao/flake-input-watcher) | Checkout path, enabled service and timer |
| `notification-history` | [Repository](https://github.com/SpreadZhao/notification-history) | fnott policy, Nixvim viewer, popup package and shortcut |
| `fzf-popup` | [Repository](https://github.com/SpreadZhao/fzf-popup) | Foot launcher, dwl window rule and callers |
| `spreadless` | [Repository](https://github.com/SpreadZhao/spreadless) | dwl settings and session launcher; slstatus components, colors and refresh interval |

These inputs follow the root `nixpkgs`. `notification-history` also follows the
root `fzf-popup` input; `spreadless` follows `naw`. Update the corresponding
input to adopt a release. Test local work with
`--override-input NAME path:/path/to/NAME --no-write-lock-file`.

## Flake input watcher

`modules/home/flake-input-watcher/default.nix` enables checks against `projDir`.
The default timer runs five minutes after graphical login and every six hours.
Host modules can override `services.flake-input-watcher` for scheduling,
input selection and hooks. Checks send fnott notifications and run matching
hooks for pending updates, including previously reported updates. They do not
change the lock file or rebuild the system.

```sh
flake-input-watcher list-inputs
flake-input-watcher check --dry-run
flake-input-watcher check
systemctl --user status flake-input-watcher.timer
journalctl --user -u flake-input-watcher.service
```

## Notification history

The listener is enabled with fnott unless overridden. It starts with the
graphical session, records incoming notifications and retains the newest 100
by default. It cannot recover notifications sent before it started. Override
`services.notification-history.maxEntries` with a positive number to change
retention.

Open `notification-history browse` or press `Mod+Ctrl+Shift+N`. Enter displays
the title and body in read-only Nixvim with word wrapping; quitting closes the
floating terminal. Escape cancels. Neither action changes the clipboard;
copying is explicit:

```sh
notification-history preview ID
notification-history view ID
notification-history copy ID
systemctl --user status notification-history.service
journalctl --user -u notification-history.service
```

The database is at
`${XDG_DATA_HOME:-$HOME/.local/share}/notification-history/history.sqlite3`.
The package receives `programs.nixvim.build.package` through a Nix override and
uses the same `fzf-popup` input as the root flake. Application behavior and the
database schema are maintained upstream.

## fzf popups

`fzf-popup` reads candidates from stdin, accepts fzf options after `--`, and
returns the selected rows and fzf exit status. Its launcher receives an argument
vector, runs it and waits for completion. `FZF_POPUP_TITLE` carries the title;
without a launcher, the program uses the current terminal.

`modules/home/fzf-popup` installs the upstream package and sets
`FZF_POPUP_LAUNCHER` in the login and user systemd environments. The launcher runs
`footclient --client-environment -a lick-foot`. dwl's `lick-foot` rule controls
floating size. Override `FZF_POPUP_LAUNCHER` for one command or pass
`--launcher EXECUTABLE` for another terminal adapter. Log out and back in after
changing the session default.

```sh
printf '%s\n' first second | fzf-popup --title 'Choose' -- --prompt='Pick> '
```

Notification history and clipboard history use this package for their selection
menus. Each caller owns its previews and actions. Terminal and window manager
integration belongs in spreadconfig; the standalone program has no dependency
on Foot or a specific compositor.
