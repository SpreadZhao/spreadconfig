# Install NixOS

The order is: prepare the disk and checkout, initialize SOPS, install NixOS,
then restore Password Store after login. A final manual activation generates
browser bookmarks from the private store.

These instructions use the repository's `spreadzhao` account and fixed paths.
For a fork, replace the user, paths and credentials before installing. SOPS
requires the shared age backup and its passphrase; Password Store requires a
separate GPG private key and passphrase. Have these and the system login
password available outside the password store.

## Prepare installation media

Download a supported `x86_64-linux` ISO from [NixOS](https://nixos.org/download/)
or the [Tsinghua mirror](https://mirrors.tuna.tsinghua.edu.cn/nixos-images/).
Verify its SHA256 against the release's checksum. A graphical ISO makes network
setup easier; the installed desktop comes from this repository.

Use Ventoy or Rufus, or write the image from Linux:

```sh
sha256sum nixos-xxx-x86_64-linux.iso
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS,MODEL
sudo dd if=nixos-xxx-x86_64-linux.iso of=/dev/sdX bs=4M conv=fsync status=progress
```

Replace the ISO name and `/dev/sdX`. The destination must be the unmounted USB
drive, not a partition or the installation disk. Writing erases the USB drive.

Boot the USB in UEFI mode, open a terminal and enter a root shell. Stay in this
shell until rebooting into the installed system.

```sh
sudo -i
test -d /sys/firmware/efi && echo 'UEFI boot confirmed'
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
```

If the UEFI check prints nothing, reboot the installation media in UEFI mode.

## Connect to the network

Use Ethernet, the graphical network settings or `nmtui` if available. For a
minimal ISO, follow the wireless steps in the
[NixOS installation manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual).
Check for an address and default route:

```sh
ip -brief address
ip route
```

### Optional proxy

Skip this section if GitHub and package downloads work directly. Replace the
example with a reachable HTTP or mixed proxy. A proxy on another device must
allow LAN clients through its firewall. Use `127.0.0.1` only if the proxy runs
inside the live system.

```sh
export http_proxy='http://192.168.1.10:7897'
export https_proxy="$http_proxy"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export no_proxy='localhost,127.0.0.1,::1,mirrors.ustc.edu.cn,mirrors.tuna.tsinghua.edu.cn'
export NO_PROXY="$no_proxy"
curl -I --connect-timeout 10 https://github.com
```

The `https_proxy` URL describes the proxy protocol, so `http://` is valid here.
The daemon needs the same variables in a temporary live-system override:

```sh
mkdir -p /run/systemd/system/nix-daemon.service.d
cat > /run/systemd/system/nix-daemon.service.d/90-install-proxy.conf <<PROXY
[Service]
Environment="http_proxy=$http_proxy"
Environment="https_proxy=$https_proxy"
Environment="HTTP_PROXY=$HTTP_PROXY"
Environment="HTTPS_PROXY=$HTTPS_PROXY"
Environment="no_proxy=$no_proxy"
Environment="NO_PROXY=$NO_PROXY"
PROXY
systemctl daemon-reload
systemctl restart nix-daemon.service
```

If the address changes, rewrite the override and restart the daemon. This
`/run` configuration disappears at reboot; configure the installed system below.

### Optional mirrors

For downloads in mainland China, set these options in the installation shell:

```sh
export NIX_CONFIG='extra-experimental-features = nix-command flakes
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
connect-timeout = 15
download-attempts = 5'
nix config show substituters
curl -I --connect-timeout 10 https://mirrors.ustc.edu.cn/nix-channels/store/nix-cache-info
```

Without mirrors, enable flakes with
`export NIX_CONFIG='extra-experimental-features = nix-command flakes'`.
Mirrors supply binary packages; source downloads may still need the proxy.
Keep signature verification and the installation media's trusted keys enabled.
See the [USTC mirror documentation](https://mirrors.ustc.edu.cn/help/nix-channels.html).
The installed system's mirrors are defined in `modules/nixos/nix.nix`.

## Partition and mount

The following example erases a disk and creates a UEFI/ext4 installation.
Replace every device path with one verified by `lsblk`. For an existing layout,
dual boot, LUKS or Btrfs, mount the intended filesystems without formatting them.

```sh
cfdisk /dev/nvme0n1
```

For a blank disk, select GPT. Create a 1 GiB partition with type `EFI System`
and a second partition using the remaining space with type `Linux filesystem`.
Review the layout before choosing `Write`, entering `yes` and quitting.

| Example partition | Filesystem | Installed mount point |
| --- | --- | --- |
| `/dev/nvme0n1p1` | FAT32 | `/boot` |
| `/dev/nvme0n1p2` | ext4 | `/` |

Format only the newly created partitions:

```sh
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/nvme0n1p1 /mnt/boot
findmnt -R /mnt
```

Mount any separate home filesystem at `/mnt/home` before cloning. If using a
swap partition, create and enable it with `mkswap` and `swapon` before generating
the hardware configuration. This example does not configure swap or hibernation.

## Clone and select the host

Keep the network environment variables set above. Open a shell with the
bootstrap tools and clone into the installed user's workspace:

```sh
nix shell nixpkgs#git nixpkgs#age nixpkgs#sops -c bash
mkdir -p /mnt/home/spreadzhao/workspaces
git clone --branch nixos https://github.com/SpreadZhao/spreadconfig.git \
  /mnt/home/spreadzhao/workspaces/spreadconfig
cd /mnt/home/spreadzhao/workspaces/spreadconfig
```

For a private remote, use existing credentials or copy a complete checkout from
a trusted device. Do not put a token in the URL. Include `flake.lock`,
`.sops.yaml`, `secrets/secrets.yaml` and `secrets/shared-age-key.age`.

Use an existing declaration only when reinstalling that same machine:
`desktop1`, `thinkbook` or `zephyrus-m16`. Otherwise
[add a host](application-layout.md#add-a-host) first. Set the target and generate
the current disk configuration:

```sh
target_host='zephyrus-m16'
test -f "hosts/$target_host/host.nix"
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  "hosts/$target_host/hardware-configuration.nix"
```

Check root, EFI, swap and encrypted-device UUIDs against the mounted filesystems.
Keep the repository's `configuration.nix`; do not replace it with the generated
one. Review the host's drivers, PRIME addresses, machine-specific services and
the display settings in `home/dwl/files/host.sh`.

### Network after the first boot

The shared proxy defaults to `http://127.0.0.1:7897` and installs Clash Verge.
It will work only after Clash has a configuration and is listening on that port.
Choose the first-boot policy before installing:

- For direct access, set `proxy.enable = false;` in the host's
  `nixos/profile.nix`. This also disables the managed proxy application.
- For a LAN proxy, keep `proxy.enable = true;` and add the module below as
  `nixos/install-proxy.nix`. Import it from the host's `configuration.nix`.
- If the local proxy is already prepared, keep the default.

```nix
{ lib, ... }:
{
  networking.proxy.default = lib.mkForce "http://192.168.1.10:7897";
}
```

Replace the address. Once Clash works locally, remove the temporary module and
its import, then rebuild and activate manually to restore the default address.

## Initialize SOPS and install

Prepare the target system's identity before the first installation:

```sh
bash ./scripts/sops-key init --root /mnt
stat -c '%U:%G %a %n' /mnt/var/lib/sops-nix/key.txt
```

Enter the encrypted backup's passphrase. The script verifies decryption before
installing the identity; the result should show `root:root 600`. See
[SOPS](sops.md) for recovery and credential maintenance.

Evaluate with a path flake so new, untracked host files are included. Keep the
existing lock file for this installation.

```sh
nix eval --raw --no-write-lock-file \
  "path:$PWD#nixosConfigurations.${target_host}.config.system.build.toplevel.drvPath"
nixos-install --root /mnt --flake "path:$PWD#$target_host"
```

The install includes Home Manager and inherits the shell's proxy and mirror
settings. If a download fails, fix connectivity or remove an unresponsive
mirror from `NIX_CONFIG`, then rerun the install. Do not repartition or regenerate
keys. Resolve all errors before rebooting.

Set root's password when prompted. The `spreadzhao` login password comes from
SOPS's `spreadzhao-password-hash`. After a successful install, hand the checkout
to the user and reboot:

```sh
nixos-enter --root /mnt -c \
  'chown spreadzhao:users /home/spreadzhao && chown -R spreadzhao:users /home/spreadzhao/workspaces'
reboot
```

Remove the USB drive. Keep the checkout at
`/home/spreadzhao/workspaces/spreadconfig`; application links depend on it.
The system can boot before Password Store exists.

## Finish after login

Run as `spreadzhao` in the graphical session:

```sh
cd ~/workspaces/spreadconfig
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt \
  sops decrypt secrets/secrets.yaml > /dev/null
gh auth status
```

If either check fails, inspect SOPS activation, network access and environment
variables before continuing. No additional `gh auth login` is needed.

Follow [Password Store](password-store.md) to clone the store, import the GPG
identity, start Secret Service and back up any conflicting quickmarks file.
Then [build and manually activate](../README.md#build-and-apply) again to generate
Chromium's bookmark policy. A build alone does not refresh bookmarks.

Configure Fcitx5, proxy subscriptions and application logins as needed. Commit
host and disk configuration changes for recovery; keep plaintext identities
outside the repository.

## Adopt an existing NixOS installation

Skip disk preparation and `nixos-install`. Place the checkout at the same fixed
path, select or add a host, and use `sudo nixos-generate-config` to generate
`/etc/nixos/hardware-configuration.nix` for it. Initialize SOPS without
`--root /mnt`.

Build and manually activate the selected host before restoring Password Store.
Use an explicit `target_host`: the current hostname may still belong to the
previous configuration. Back up regular files that conflict with Home Manager
links. Then follow the post-login steps above.
