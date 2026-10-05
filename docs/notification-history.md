# Notification history integration

The program, database schema, module and usage reference are maintained in
[SpreadZhao/notification-history](https://github.com/SpreadZhao/notification-history).
This repository consumes its locked flake input and enables the service when
`services.fnott.enable` is true, unless explicitly overridden.

Open history with `notification-history browse` or `Mod+Ctrl+Shift+N`. Enter opens
the title and complete body in read-only Neovim inside the same floating terminal.
It uses the configured Nixvim package with word wrapping (`wrap` and `linebreak`)
enabled in the notification window; quitting Neovim closes the window. Escape
cancels the menu, and neither action changes the clipboard. The explicit `copy ID`
command remains available. The private temporary file is deleted after viewing.
The existing SQLite database remains at
`${XDG_DATA_HOME:-$HOME/.local/share}/notification-history/history.sqlite3`.

```sh
notification-history preview ID
notification-history view ID
notification-history copy ID
systemctl --user status notification-history.service
journalctl --user -u notification-history.service
```

Browsing uses the configured `fzf-popup` package, shared with clipboard history
and the Foot application launcher. The Foot launcher adapter and the `lick-foot`
Niri floating rule belong to spreadconfig. See [independent applications](independent-apps.md).
The integration also injects `programs.nixvim.build.package` through the package's
overridable `neovim` dependency.
The external program contains no Foot, Niri or `$SCRIPT_HOME` references.

The listener starts with the graphical session after the configuration is applied.
It observes incoming desktop notification requests and retains them across
restarts; it cannot recover requests sent before the listener started. It retains
the newest 100 notifications by default and removes older records on listener
startup and after each write. Configure a positive maximum through Home Manager:

```nix
services.notification-history.maxEntries = 100;
```
