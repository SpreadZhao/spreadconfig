---
name: android-dev
description: Work on Gradle builds, Android SDK setup, adb devices, emulator or physical-device debugging, logs, APK inspection, or app packaging in Android projects using a spreadconfig workspace development environment.
---

# Android Dev

Use this skill for Android app development. The spreadconfig Android template
provides the development tools and selects this centrally maintained skill.

## Environment

- Enter the project environment with `nix develop` or `direnv allow`.
- Prefer the project Gradle wrapper `./gradlew` when it exists. Use the shell's
  `gradle` package only when the project has no wrapper.
- Where the platform is supported by its package, `android-cli` is installed by
  the dev shell as the `android` command. Check availability before using it;
  adb and Gradle remain usable without it.
- `ANDROID_HOME` and `ANDROID_SDK_ROOT` default to
  `${XDG_LIB_HOME:-$HOME/Lib}/Android/Sdk`.
- The shell adds `$ANDROID_HOME/platform-tools` and
  `$ANDROID_HOME/cmdline-tools/latest/bin` to `PATH`.

## Checks

Run the project's `scripts/android-doctor`, when present, if Android tooling behaves unexpectedly. It
prints the SDK path, verifies `adb`, checks `android --version`, lists devices,
and checks Gradle.

Useful commands:

```bash
android info
android docs search <keywords>
android sdk list --all
adb devices
adb logcat
./gradlew tasks
./gradlew assembleDebug
./gradlew test
./gradlew connectedDebugAndroidTest
```

## Skills

The project's flake selects skills through `mkWorkspace`.
Entering `nix develop` prepares `.agents/skills` and, when enabled,
`.claude/skills`. Change the flake selection and re-enter the environment to
update these links. Do not edit generated state under `.agent-workspace`.

This skill is maintained in the central spreadconfig checkout. Source edits
are visible immediately to workspaces that select it.

## Debugging

- Check `adb devices` before assuming an app or test failure.
- Use `adb logcat` for runtime crashes and Android framework errors.
- Use `android docs search` for current Android documentation.
- Use `jadx` for APK inspection when source is unavailable.
- Use `scrcpy` when a physical device needs to be viewed or controlled.

## Boundaries

Do not install or update Android SDK packages globally unless the user asks.
Assume Android Studio manages the SDK. If an SDK component is missing, report
the exact missing path or tool first.
