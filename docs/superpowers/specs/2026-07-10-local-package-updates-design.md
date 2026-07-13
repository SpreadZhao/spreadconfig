# Local Package Updates in `nix_update`

## Goal

Make every package exported from `packages/default.nix` participate in the
normal update workflow. `nix_update` and `nix_full_update` must both update
flake inputs and local packages without a new opt-in flag. The only behavioral
difference between the two commands remains the cleanup performed by
`nix_full_update`.

## Required Command Behavior

`nix_update [switch|boot]` executes these stages in order:

1. Update all non-excluded root flake inputs using the existing retry logic.
2. Update every package exported through `packages.<system>`.
3. Build every exported local package to validate the updated sources.
4. Run `sns_until` with the requested action.

`nix_full_update [switch|boot]` continues to call `nix_update` and then runs
`nix_clean`. It does not implement a separate package update path.

There is no flag for enabling or disabling local package updates. Existing
flake-input exclusion options remain unchanged and apply only to flake inputs.

## Package Update Contract

Every package exported from `packages/default.nix` must expose a
`passthru.updateScript`. Adding a package without an updater is a configuration
error, not an implicit exclusion.

The updater implementation belongs with the package:

- Standard GitHub release packages use `nix-update-script` and expose the
  actual fetched archive through `passthru.src` when the wrapper derivation
  otherwise hides it.
- Packages with local npm metadata use a package-specific updater that keeps
  `default.nix`, `package.json`, and `package-lock.json` on the same version.
- Packages with more than one upstream artifact, such as `cc-connect`, verify
  that all upstream versions agree before changing any files.
- Packages with non-standard release discovery, such as `zcode`, use a small
  package-specific updater that reads the official release source and refreshes
  both the version and fixed-output hash.

Update scripts must be idempotent. Running an updater when the package is
already current exits successfully without changing files. Update scripts do
not create commits.

## Orchestration

Add a shared `update_local_packages` command under the existing Nix script
tree. It performs a preflight evaluation of `packages.<system>` before making
changes:

1. Discover package attribute names from the root flake instead of maintaining
   a second package list.
2. Sort the names for deterministic logs and execution.
3. Verify that every package exposes `updateScript`.
4. Execute each package updater sequentially through `nix-update --flake
   --use-update-script`.
5. Build all discovered package attributes with `nix build --no-link`.

The existing `nix_update` command invokes this command after flake input updates
and before `sns_until`. `nix-update` is installed declaratively so the runtime
script never downloads an updater through an unpinned `nix run` invocation.

## Failure Semantics

The workflow is strict:

- A missing package updater fails the entire command during preflight.
- A release lookup, metadata update, hash refresh, or package build failure
  exits nonzero immediately.
- `sns_until` is not called after a local package failure.
- Because `nix_full_update` delegates to `nix_update` under `set -e`, cleanup is
  not called after a failure either.

Files changed by successful earlier package updaters remain in the working tree
when a later updater fails. The command does not perform an automatic rollback,
because restoring files could overwrite pre-existing user changes and the
partial diff is useful for diagnosing the failed update.

## Package-Specific Strategy

| Package | Update source | Strategy |
| --- | --- | --- |
| `bili23-downloader` | GitHub releases | `nix-update-script` plus archive hash refresh |
| `github-copilot-app` | GitHub releases | `nix-update-script` plus AppImage hash refresh |
| `zcode` | Official ZCode release/download metadata | Custom version and AppImage hash updater |
| `docsify-cli` | npm | Custom npm metadata and lockfile updater |
| `cc-connect` | npm and GitHub/Gitee binary releases | Custom synchronized metadata, lockfile, and binary hash updater |

## Verification

Implementation verification must cover:

- `bash -n`, `shellcheck`, and `shfmt` for changed shell scripts.
- `nixfmt` and `git diff --check` for changed Nix files.
- A preflight evaluation proving every exported package has an updater.
- A no-op updater run when package versions are already current.
- A successful `nix build --no-link` for every local package.
- A failure-path test with a stub updater proving that `sns_until` is not run.
- A failure-path test proving that `nix_full_update` does not run `nix_clean`
  when `nix_update` fails.
- Home Manager activation-package evaluation for both hosts when the updater
  runtime package is added to shared Home Manager configuration.

Actual `switch`, `boot`, and cleanup operations are not part of automated
verification unless explicitly requested.
