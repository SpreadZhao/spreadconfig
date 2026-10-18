# SOPS credentials

All hosts use one age identity to decrypt `secrets/secrets.yaml`. Its encrypted
backup, `secrets/shared-age-key.age`, is safe to track in Git. The local plaintext
identity belongs at `/var/lib/sops-nix/key.txt`, owned by root with mode `0600`.
Keep it outside the repository and Nix store; persist `/var/lib/sops-nix` if the
root filesystem is temporary.

SOPS handles system credentials. Password Store uses a separate
[GPG identity](password-store.md). For the installation sequence, see
[install](install.md).

## Initialize a machine

Sync `.sops.yaml`, `secrets/secrets.yaml` and `secrets/shared-age-key.age`, then
run from the checkout:

```sh
nix shell nixpkgs#age nixpkgs#sops -c bash ./scripts/sops-key init
```

For a fresh installation mounted at `/mnt`, append `--root /mnt`. Enter the
shared backup passphrase when prompted. The script verifies decryption before
installing the key. Reruns verify the existing key; a mismatched key is never
overwritten. This does not generate a new identity or rotate any credentials.

The backup passphrase protects only the encrypted copy. Each initialized host
holds the same plaintext key, so a leaked key exposes all shared secrets.

## Edit credentials

Verify decryption without printing secrets:

```sh
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt \
  sops decrypt secrets/secrets.yaml > /dev/null
```

Edit with the same identity:

```sh
sudo env SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt sops edit secrets/secrets.yaml
```

Commit and sync the ciphertext, then build and manually activate each host.
Plaintext credentials are rendered at activation, never during evaluation.

## GitHub authentication

Nix and GitHub CLI share `github-token`. `modules/nixos/secrets.nix` renders
files owned by `spreadzhao:users`, mode `0400`:

| Template | Consumer |
| --- | --- |
| `nix-github-access-tokens.conf` | Nix reads it through `!include` in `nix.conf`; token changes restart `nix-daemon` |
| `gh-hosts.yml` | Home Manager links it to `~/.config/gh/hosts.yml`; `gh` also supplies HTTPS Git credentials |

The optional include lets the first build succeed before the runtime file
exists. Activate the initial configuration before updating private inputs.
SSH remotes still use SSH keys.

Home Manager sets `GH_CONFIG_DIR` to its `gh` configuration directory
(`~/.config/gh`) for login shells and user systemd services. This keeps the
managed login available when Codex uses isolated XDG directories. After changing
the session environment, activate the configuration and log out of the desktop,
then log back in before starting Codex. Individual commands can override
`GH_CONFIG_DIR` to use a temporary configuration.

Check the managed login with `gh auth status`. Remove persistent `GH_TOKEN`,
`GITHUB_TOKEN` or `GH_CONFIG_DIR` overrides if they select another login. Home Manager owns the linked credential file. Do not use `gh auth login`, `logout`, `switch` or `refresh` on the read-only file.

To replace the token, edit `github-token` in SOPS and deploy it to every host.
If browser authorization is needed, use a temporary GitHub CLI configuration:

```sh
gh_setup_dir=$(mktemp -d)
env -u GH_TOKEN -u GITHUB_TOKEN GH_CONFIG_DIR="$gh_setup_dir" \
  gh auth login --hostname github.com --git-protocol https --web --insecure-storage
env -u GH_TOKEN -u GITHUB_TOKEN GH_CONFIG_DIR="$gh_setup_dir" \
  gh auth token --hostname github.com
```

Copy the locally displayed token into SOPS, then remove the temporary directory
with `rm -rf -- "$gh_setup_dir"` and `unset gh_setup_dir`. Keep the shared token
nonempty and valid. Revoke the old token after deploying its replacement.

## Claude Code

`claude-settings.json` in `modules/nixos/secrets.nix` sets the Anthropic-compatible
GLM endpoint, model aliases and context limits. The current model is `glm-5.3`;
`glm-api-key` supplies its encrypted credential. Home Manager links the rendered
file to `~/.claude/settings.json`, owned by `spreadzhao:users`, mode `0400`.

Change persistent settings in the template or SOPS, then build, manually activate
and restart Claude Code. Check `/status` for the active model. Onboarding and
other mutable state remain in `~/.claude.json`.
