---
name: smartmontools-disk-health
description: Use when checking disk, SSD, or NVMe S.M.A.R.T. health with root-only smartmontools commands, interpreting smartctl output, running self-tests, diagnosing smartd, or adding NixOS smartd monitoring configuration.
---

# Smartmontools Disk Health

## Overview

Use this skill to inspect disk health with `smartctl`, configure continuous monitoring with `smartd`, and encode the result declaratively in NixOS. Prefer device evidence from the current machine over assumptions.

## Privileges

Run real device checks with root privileges. In non-interactive agent contexts, prefer `sudo -n smartctl ...` and `sudo -n smartd ...`; if sudo is unavailable, report that the health check cannot be completed and give the exact command for the user to run.

Do not interpret non-root `smartctl --scan` empty output, `/dev/nvme*` "No such device", or systemd bus access failures as disk absence. Those are usually permission or sandbox boundaries.

## Workflow

1. Identify whole-disk devices with `lsblk -o NAME,TYPE,SIZE,MODEL,SERIAL,WWN,TRAN,ROTA,MOUNTPOINTS` and `sudo smartctl --scan` or `sudo smartctl --scan-open`. Ignore partitions unless the device type explicitly requires otherwise.
2. For persistent NixOS configuration, prefer `/dev/disk/by-id/...` paths over `/dev/sdX` or `/dev/nvmeXnY` when available.
3. Read current health before changing monitoring:
   - `sudo smartctl -i -H -A -l error -l selftest DEVICE`
   - use `sudo smartctl -a DEVICE` or `sudo smartctl -x DEVICE` when the short report is not enough.
4. Check capability and test duration with `sudo smartctl -c DEVICE` before scheduling or running self-tests.
5. Run non-captive self-tests only when appropriate:
   - short: `sudo smartctl -t short DEVICE`
   - long: `sudo smartctl -t long DEVICE`
   - results: `sudo smartctl -l selftest DEVICE`
6. Configure NixOS smartd only after deciding whether autodetection is enough or explicit devices are safer.
7. Validate with Nix eval/build checks. Do not switch or boot unless the user asks.

## NixOS Pattern

For a simple shared module:

```nix
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.smartmontools ];

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
```

Use explicit `services.smartd.devices` when USB bridges, RAID controllers, removable disks, or unstable device names make autodetection too broad or too noisy.

## Read More

Read [references/smartmontools.md](references/smartmontools.md) when you need option details, smartd directive examples, NixOS explicit-device examples, or interpretation heuristics.
