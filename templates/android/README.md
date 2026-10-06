# Android Development Workspace

Initialize an empty project directory from this template:

```bash
nix flake init --template github:SpreadZhao/spreadconfig#android
```

Edit `flake.nix` to select skills, packages and Claude support, then run
`nix develop`. If using direnv, review `.envrc`
and enable it with `direnv allow`.

The template uses the common `spreadconfig.lib.mkWorkspace` implementation. It
selects the centrally maintained `android-dev` skill and the official Android
skills from the pinned `android-skills` input. Official skill names come from
`SKILL.md` frontmatter; duplicate names or conflicts with the central catalog fail
before any project links change. Remove or filter `extraSkills` if you do not
want the full official collection.

The personal `android-dev` skill uses spreadconfig's locked personal-skills input.
Update that input after editing content. Official Android skills use their pinned
input through extraSkills. Both sources use the independent agent-workspace engine.
Changed source links require removing their specific old entry before installation.
For current local use, override spreadconfig to
path:/home/spreadzhao/workspaces/spreadconfig before entering.

Entering the environment prepares `.agents/skills`, `AGENTS.md` and management
state under `.agent-workspace/`. Set `claude = true` for `.claude/skills` and a shared
`CLAUDE.md` entry. Re-enter `nix develop` after changing selections or inputs.
Generated state and its store GC root are ignored by Git; keep `flake.lock` in
version control. Existing user files and unrelated links are not replaced. There
is no separate skill installation command.

Start agent sessions from this workspace directory. An independently opened
nested Git repository may have a different skill-discovery root.

## Android tooling

The shell provides `android-cli`, Android tools, Gradle, Java 17, Kotlin, JADX,
ktlint, protobuf, ripgrep and scrcpy. Prefer a project's `./gradlew` when present.
Run `scripts/android-doctor` from the project directory to check SDK and device
availability.

Both x86_64 Linux and aarch64 Linux are supported. `android-cli` is included only
where its pinned Nix package is available (currently x86_64 Linux); SDK, adb and
Gradle tooling remain available on aarch64 Linux.

The Android SDK stays outside Nix, typically managed by Android Studio. Its path
uses the first available value:

1. `ANDROID_HOME`
2. `ANDROID_SDK_ROOT`
3. `$XDG_LIB_HOME/Android/Sdk`
4. `$HOME/Lib/Android/Sdk`

Both Android variables are set to the selected path, and the SDK's
`platform-tools` and `cmdline-tools/latest/bin` are added to `PATH`. The shell does
not download or modify SDK components.
