# Flake input watcher integration

The program, Home Manager module and full configuration reference are
maintained in [SpreadZhao/flake-input-watcher](https://github.com/SpreadZhao/flake-input-watcher).
This repository consumes its locked flake input.

`modules/home/flake-input-watcher/default.nix` enables the external module and
sets `flakePath` to the existing `projDir`. By default, all hosts check five
minutes after graphical login and every six hours. Notifications use
`notify-send` and fnott. Host modules can override `services.flake-input-watcher`
settings, including input switches, hooks, rules and scheduling.

```sh
flake-input-watcher list-inputs
flake-input-watcher check --dry-run
flake-input-watcher check
systemctl --user status flake-input-watcher.timer
journalctl --user -u flake-input-watcher.service
```

The existing `~/scripts/nix/flake-input-watcher` is a compatibility forwarding
script. The actual executable is supplied by the external package. Existing
XDG check lock remains compatible. Each check executes matching hooks for all
pending updates, even if a previous check already reported them; legacy action
history is ignored. The checker does not modify locks or rebuild the system.
Applying the system configuration is separate from editing or building this
repository.
