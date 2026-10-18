# JetBrains IDEs

This module installs Android Studio, IntelliJ IDEA and CLion. `default.nix`
selects the IDEs, `plugins.nix` lists plugins, `sdk.nix` selects Android components,
and `settings.nix` manages shared settings. Assets live in `files/`. Launchers
come from `personal-packages.lib.mkJetBrainsIde` in nix-packages.

Plugins are resolved against each IDE by nix-jetbrains-plugins and loaded from
an immutable directory. Update nixpkgs for IDE versions and the plugin input
for plugins; check that the index supports the new IDE version. Toolbox and IDE
self-updates are not used.

True Dark 3.0.0 references missing Islands editor-scheme parents. The versioned
patch in `plugins.nix` replaces three parent names with Darcula/Default while
keeping the True Black UI. Recheck this patch when updating the plugin.

## Toolchains

Android Studio uses the Nix SDK at `~/Lib/Android/Sdk`. Change components in
`sdk.nix`; SDK Manager and the installation wizard do not manage this SDK.
Emulator images, NDK and Android CMake are omitted.

Android Studio and IDEA receive JDK 21 and `JAVA_HOME`; the IDE processes use
their upstream JBR. CLion receives GCC, CMake, Ninja and GDB. These environments
apply to both terminal launchers and desktop entries. Android Studio explicitly
sets `ANDROID_HOME` and `ANDROID_SDK_ROOT`. Project Gradle JVM settings still
apply, and terminal builds should use their project's devShell.

## Settings and migration

Configuration and caches are separated by IDE and major/minor version under
`~/.config/jetbrains` and `~/.cache/jetbrains`. Activation restores True Black,
the SpreadZhao editor scheme and the Nix CLion toolchain. Close IDEs before
activation so they cannot overwrite those settings on exit.

A one-time migration removes only the old managed JDK 21 `org.gradle.java.home`
value, preserving other content and user-managed symlinks. Its marker is
`$XDG_STATE_HOME/jetbrains/migrations/gradle-java-home-v1`. Old managed JDK links
under `~/Lib/jdks` are retired; Gradle caches remain intact.

The editable `.ideavimrc` keeps Quickscope disabled. Launchers set
`QT_IM_MODULE=fcitx` and provide the Fcitx remote tool and `busctl` for
IdeaVimExtension. Session-wide input-method settings are unchanged.

For changes spanning nix-packages and this repository, validate with
`--override-input personal-packages path:/path/to/nix-packages --no-write-lock-file`.
Publish that dependency before updating the lock file; keep local paths out of
committed locks. Build first and activate manually, then restart IDEs to use the
new launcher environment.
