# Smartmontools Reference

This reference summarizes `smartctl(8)`, `smartd(8)`, and `smartd.conf(5)` usage for practical disk health monitoring. Treat it as an operator guide, not as a replacement for backups.

## Privilege Model

Use root privileges for real SMART/NVMe access:

```bash
sudo smartctl --scan-open
sudo smartctl -a DEVICE
sudo smartd -q onecheck
```

In non-interactive agent runs, prefer `sudo -n` so commands fail quickly instead of blocking for a password:

```bash
sudo -n smartctl -a DEVICE
sudo -n smartd -q onecheck
```

If `sudo -n` fails, stop and report the exact command the user should run locally. Do not treat these as health results:

- `smartctl --scan` returns no devices without sudo.
- `smartctl open device: DEVICE failed: No such device` inside a sandbox.
- `systemctl` cannot connect to the system bus inside a sandbox.
- `/dev/nvme*` or `/dev/sd*` is missing only inside the restricted environment.

## Device Discovery

Useful commands:

```bash
lsblk -o NAME,TYPE,SIZE,MODEL,SERIAL,WWN,TRAN,ROTA,MOUNTPOINTS
sudo smartctl --scan
sudo smartctl --scan-open
ls -l /dev/disk/by-id/
```

Guidelines:

- Monitor whole disks, for example `/dev/nvme0n1`, `/dev/sda`, or persistent `/dev/disk/by-id/...` paths.
- Prefer `/dev/disk/by-id/...` in NixOS config because kernel names can change across boots.
- `--scan-open` tries to open devices and should be run with sudo.
- For USB enclosures or RAID controllers, `smartctl --scan` may suggest a required `-d TYPE`.

## One-Time Health Check

Start with:

```bash
sudo smartctl -i -H -A -l error -l selftest DEVICE
```

Escalate to:

```bash
sudo smartctl -a DEVICE
sudo smartctl -x DEVICE
```

Important options:

- `-i`: identity, model, serial, firmware, protocol.
- `-H`: overall SMART health. A failing result is urgent.
- `-A`: vendor attributes for ATA/SATA and health log values for NVMe.
- `-a`: common complete SMART report. For NVMe this includes health, identity, capabilities, attributes, error log, and self-test log.
- `-x`: extended report with extra SMART and non-SMART logs when supported.
- `-l error`: error log.
- `-l selftest`: self-test history.
- `-c`: capabilities and estimated self-test duration.
- `-j`: JSON/YAML output when a script needs parsing.

## Interpreting Common Signals

High-risk signals:

- overall health check fails.
- ATA `Reallocated_Sector_Ct`, `Current_Pending_Sector`, or `Offline_Uncorrectable` is nonzero or increasing.
- SMART error log or self-test log records recent failures.
- NVMe `Critical Warning` is nonzero.
- NVMe `Media and Data Integrity Errors` is nonzero or increasing.
- NVMe `Percentage Used` is near or above 100.
- temperature is consistently high for the device class.

Cautions:

- SMART attributes are vendor-specific; raw values are not always comparable across models.
- A passing SMART health result does not prove the disk is safe.
- Always recommend backup or replacement planning before invasive troubleshooting if data matters.

## Self-Tests

Check support and duration first:

```bash
sudo smartctl -c DEVICE
```

Run tests:

```bash
sudo smartctl -t short DEVICE
sudo smartctl -t long DEVICE
sudo smartctl -t conveyance DEVICE
```

Read results:

```bash
sudo smartctl -l selftest DEVICE
```

Rules:

- Use non-captive tests by default. They can run during normal operation, but may degrade drive performance.
- Avoid `-C` captive mode unless the user explicitly accepts foreground disruption.
- Only one self-test should be started per command.
- If the machine powers off during a self-test, the test may abort or resume depending on the device.

## Smartd Operation

Service diagnostics:

```bash
systemctl status smartd
journalctl -u smartd -b
sudo smartd -q onecheck
sudo smartd -q showtests
```

Useful `smartd` modes:

- `-q onecheck`: register devices, check SMART once, then exit.
- `-q showtests`: show future scheduled tests and exit.
- `-d`: debug foreground mode.
- `-i N`: polling interval in seconds; minimum is 10, default is usually 1800.

## Smartd Directives

Common `smartd.conf` directives:

- `DEVICESCAN`: scan and monitor discovered devices. `DEVICESCAN -a` is the broad default pattern.
- `-a`: broad monitoring set; includes health, prefailure/usage tracking, error log, self-test log, and self-test status.
- `-H`: monitor overall health.
- `-l error`: monitor SMART error log changes.
- `-l selftest`: monitor self-test log changes.
- `-s REGEXP`: schedule tests. Examples: `S/../.././03` for daily short tests around 03:00, `L/../../7/04` for Sunday long tests around 04:00.
- `-n standby,q`: skip checks that would wake sleeping ATA/SCSI disks and stay quiet when skipped.
- `-W DIFF,INFO,CRIT`: temperature reporting thresholds.
- `-m ADDRESS`: send warning mail. On NixOS, confirm local mail delivery before relying on this.
- `-M TYPE`: modify mail behavior, such as test or exec modes.
- `-o on`: enable ATA automatic offline testing at smartd startup when supported.
- `-S on`: enable ATA attribute autosave at smartd startup.
- `-d TYPE`: force device type, useful for SAT USB bridges or RAID controllers.

If logs are too noisy, prefer a smaller directive set such as `-H -l selftest -l error -f`. Use `-a` when full monitoring is desired.

## NixOS Configuration

Simple shared monitoring:

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

Explicit devices:

```nix
{
  services.smartd = {
    enable = true;
    autodetect = false;
    devices = [
      {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_SERIAL";
        options = "-a -n standby,q -W 2,50,60 -s (S/../.././03|L/../../7/04)";
      }
    ];
  };
}
```

Use explicit devices when:

- a removable or USB device causes repeated errors.
- a controller requires `-d TYPE`.
- only selected disks should be monitored.
- stable persistent names are important.

Validation commands for this repository:

```bash
nixfmt modules/nixos/smartmontools.nix
git diff --check
nix eval --raw --no-eval-cache .#nixosConfigurations.HOST.config.system.build.toplevel.drvPath
```

Do not apply the system unless the user explicitly asks.
