# Android Development Template

This template provides a Nix dev shell for Android projects, `android-cli`, and
project-local agent skills under `.agents/skills`.

Enter the environment with:

```bash
direnv allow
```

or:

```bash
nix develop
```

The shell expects the Android SDK to be managed outside Nix, usually by Android
Studio. By default it uses:

```text
$XDG_LIB_HOME/Android/Sdk
```

falling back to:

```text
$HOME/Lib/Android/Sdk
```

Override it with `ANDROID_HOME` or `ANDROID_SDK_ROOT` when needed.

The official Android skills repository is pinned as a flake input. Entering the
dev shell scans that input for every `SKILL.md`, reads each skill's frontmatter
`name:`, and installs symlinks into:

```text
.agents/skills
```

You can refresh those links manually with:

```bash
nix run .#install-android-skills
```

The installer tracks official Android skills in
`.agents/skills/.android-skills-managed`, so skills removed from the upstream
input are pruned on the next install without deleting unmanaged local files.
