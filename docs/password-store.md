# Password Store

Restore Password Store after installing NixOS and logging in as `spreadzhao`.
Its GPG key is separate from the [SOPS age identity](sops.md). Run the commands
below in the user's graphical session, without `sudo`.

## Restore the GPG identity

Check GitHub authentication, then clone the private store. If the destination
already exists, inspect it before proceeding; keep its contents and `.gpg-id`.

```sh
gh auth status
git clone https://github.com/SpreadZhao/password-store.git ~/.password-store
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
cat ~/.password-store/.gpg-id
gpg --show-keys --with-fingerprint ~/.password-store/backup/gpg_pub_backup.pgp
gpg --show-keys --with-fingerprint ~/.password-store/backup/gpg_bakcup.pgp
```

Match the full primary-key fingerprints against `.gpg-id` and a trusted record
from the original machine. Matching email addresses alone are insufficient.
`gpg_bakcup.pgp` is the backup's existing filename.

```sh
gpg --import ~/.password-store/backup/gpg_pub_backup.pgp
gpg --import ~/.password-store/backup/gpg_bakcup.pgp
gpg --list-secret-keys --keyid-format long
printf '%s:6:\n' '<verified-primary-key-fingerprint>' | gpg --import-ownertrust
pass ls
pass show '<existing-entry-without-.gpg>' > /dev/null
```

Grant ultimate trust only to the verified identity you own. Psst prompts for the
private-key passphrase locally. If the backup lacks a usable secret key, recover
it from the original device; a new key or `pass init` cannot decrypt old entries.

Pass works as soon as the key is restored. Activation does not import keys,
clone or sync the store, or re-encrypt entries. Use the store's own Git workflow
to sync it. Private keys, passwords and bookmark contents stay outside the Nix store.

## Start Secret Service

`PASSWORD_STORE_DIR` and the service's `storePath` point to `~/.password-store`.
The service skips startup while `.gpg-id` is missing. After restoring the store:

```sh
systemctl --user restart pass-secret-service.service
systemctl --user is-active pass-secret-service.service
busctl --user status org.freedesktop.secrets
```

GPG agent starts on demand through its sockets; an inactive process alone does
not indicate a fault. Password menus are available as `~/scripts/util/bin/pmenu`
and `pmenu_last`.

If Git ignores `secret_service/`, cloning will not restore application
credentials stored there. Restore that directory's encrypted backup and its
`.properties` metadata separately.

## Shared browser bookmarks

Home Manager links `~/.config/qutebrowser/quickmarks` to
`~/.password-store/qutebrowser/qutebrowser_quickmarks`. Qutebrowser reads and
writes this file directly. Before activation, quit qutebrowser and back up any
regular file occupying the link path, even if it is empty:

```sh
if [ -f ~/.config/qutebrowser/quickmarks ] && [ ! -L ~/.config/qutebrowser/quickmarks ]; then
  mv ~/.config/qutebrowser/quickmarks \
    ~/.config/qutebrowser/quickmarks.before-spreadconfig."$(date +%Y%m%d-%H%M%S)"
fi
```

Do not overwrite the private store's bookmarks. A correct existing link needs
no action. The `m` and `M` bindings save quickmarks; use `:save quickmark-manager`
to flush edits before activating.

System activation, including boot, converts quickmarks into Chromium's
read-only policy at `/etc/chromium/policies/managed/qutebrowser-bookmarks.json`.
Builds do not read bookmark contents or refresh that policy. A missing source is
skipped, an empty source clears the managed bookmarks, and conversion failure
keeps the previous policy. The converter leaves the source unchanged.

Edit bookmarks in qutebrowser and sync the private repository normally. After
restoring it on a new machine, [build and manually activate](../README.md#build-and-apply)
once more to generate Chromium's policy.
