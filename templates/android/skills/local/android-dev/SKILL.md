---
name: android-dev
description: Use in Android projects created from the spreadconfig Android flake template when working on Gradle builds, Android SDK setup, adb devices, emulator or physical-device debugging, logs, APK inspection, or app packaging.
---

# Android Dev

Use this skill for Android app development inside a project created from the
spreadconfig Android template.

## Environment

- Enter the project environment with `nix develop` or `direnv allow`.
- Prefer the project Gradle wrapper `./gradlew` when it exists. Use the shell's
  `gradle` package only when the project has no wrapper.
- `android-cli` is installed by the dev shell as the `android` command.
- `ANDROID_HOME` and `ANDROID_SDK_ROOT` default to
  `${XDG_LIB_HOME:-$HOME/Lib}/Android/Sdk`.
- The shell adds `$ANDROID_HOME/platform-tools` and
  `$ANDROID_HOME/cmdline-tools/latest/bin` to `PATH`.

## Checks

Run `scripts/android-doctor` when Android tooling behaves unexpectedly. It
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

Entering the dev shell runs `install-android-skills`, which scans the pinned
official Android skills input and installs project skill symlinks under
`.agents/skills`. Run this manually after flake input updates:

```bash
nix run .#install-android-skills
```

Official Android skills are tracked in `.agents/skills/.android-skills-managed`.
Do not edit that manifest by hand unless you are repairing stale symlinks.

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
