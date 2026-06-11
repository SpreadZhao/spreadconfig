---
name: android-waydroid-control
description: Control local Waydroid or Android devices through Android Studio SDK adb for automated app debugging. Use when Codex needs to start/connect Waydroid, verify Android Studio/adb visibility, drive taps/swipes/text/keyevents, capture screenshots, dump UI XML, install/launch APKs, read logcat, or inspect app state from an Android runtime.
---

# Android Waydroid Control

Use this skill to make Android UI debugging agent-controllable. Prefer the user's Android Studio SDK adb at `~/Android/Sdk/platform-tools/adb`; do not install a global adb unless the user explicitly asks.

## Tooling

Use these paths and commands by default:

```bash
ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
WAYDROID=waydroid
```

If `ANDROID_HOME` is unset, assume `~/Android/Sdk`. Verify `"$ADB" version` before using adb. If Waydroid is the target, verify `waydroid status`.

## Workflow

1. Start or show Waydroid:

```bash
waydroid show-full-ui
```

If a foreground command would block the Codex tool session, run it from a normal user shell or use `nohup waydroid show-full-ui >/tmp/waydroid-ui.log 2>&1 &`.

2. Connect adb:

```bash
SERIAL="$(waydroid status | awk -F '\t' '$1 == "IP address:" { print $2 ":5555" }')"
"$ADB" connect "$SERIAL"
"$ADB" devices -l
```

If the device is `unauthorized`, open the Waydroid UI and accept the RSA prompt. If it is `offline`, run:

```bash
"$ADB" disconnect "$SERIAL"
"$ADB" kill-server
"$ADB" start-server
"$ADB" connect "$SERIAL"
```

Waydroid may report `Container: FROZEN` when the UI has gone idle. Before sending adb shell/input/screencap commands, wake or restart the session so `waydroid status` reports `Container: RUNNING`. The bundled helper does this automatically.

3. Always select a target serial explicitly when issuing commands:

```bash
SERIAL="$("$ADB" devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')"
"$ADB" -s "$SERIAL" shell getprop ro.product.model
```

## Common Controls

Use `input` for gestures:

```bash
"$ADB" -s "$SERIAL" shell input tap 540 1800
"$ADB" -s "$SERIAL" shell input swipe 500 1800 500 600 300
"$ADB" -s "$SERIAL" shell input text 'hello%sworld'
"$ADB" -s "$SERIAL" shell input keyevent KEYCODE_BACK
"$ADB" -s "$SERIAL" shell input keyevent KEYCODE_HOME
```

Use screenshots and UI dumps for observation:

```bash
"$ADB" -s "$SERIAL" exec-out screencap -p > /tmp/waydroid-screen.png
"$ADB" -s "$SERIAL" shell uiautomator dump /sdcard/window.xml
"$ADB" -s "$SERIAL" exec-out cat /sdcard/window.xml > /tmp/waydroid-window.xml
```

On Waydroid, `screencap` can emit graphics warnings before the PNG stream. Strip any leading bytes before the PNG header if capturing screenshots manually. The bundled helper handles this.

When inspecting screenshots, use local image viewing tools available to Codex. When inspecting UI XML, search for `text=`, `resource-id=`, `content-desc=`, and `bounds=`.

## App Debugging

Install and launch apps:

```bash
"$ADB" -s "$SERIAL" install -r app-debug.apk
"$ADB" -s "$SERIAL" shell monkey -p com.example.app 1
```

Inspect activity and logs:

```bash
"$ADB" -s "$SERIAL" shell dumpsys activity top
"$ADB" -s "$SERIAL" logcat -d -t 300
"$ADB" -s "$SERIAL" logcat -c
```

Use a loop of screenshot -> UI dump -> targeted input -> logcat. Report concrete device state and artifacts paths.

## Helper Script

The bundled `scripts/waydroid_adb_control.sh` wraps the common operations while still using Android Studio SDK adb. Prefer it for repeatable actions:

```bash
SKILL_DIR="$HOME/.codex/skills/android-waydroid-control"
"$SKILL_DIR/scripts/waydroid_adb_control.sh" start
"$SKILL_DIR/scripts/waydroid_adb_control.sh" screenshot /tmp/waydroid.png
"$SKILL_DIR/scripts/waydroid_adb_control.sh" tap 540 1800
"$SKILL_DIR/scripts/waydroid_adb_control.sh" dump-ui /tmp/window.xml
```

If the helper reports `unauthorized`, open the UI and accept the RSA prompt. If the helper blocks while launching the UI, stop the foreground process and use the `show` command again from a user shell.
