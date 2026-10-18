# JetBrains IDEs and private development tools

This module installs Android Studio, IntelliJ IDEA, and CLion on every host.
`default.nix` declares the IDEs, `plugins.nix` holds the shared plugin IDs,
`sdk.nix` pins Android components, and `settings.nix` declares shared settings.
Personal assets are in `files/`; the reusable launcher is
`personal-packages.lib.mkJetBrainsIde` from the separate nix-packages repository.

Plugins are resolved against each upstream IDE by nix-jetbrains-plugins and
loaded from an immutable Nix directory. Update the plugin flake input to update
plugins; update nixpkgs to update IDEs. Neither Toolbox nor IDE self-updates are
used. When bumping the IDE version, verify its version exists in the plugin
index before applying the configuration.

True Dark 3.0.0 references missing Islands editor scheme parents. `plugins.nix`
patches only those three XML parent names to Darcula/Default, leaving the selected
True Black UI theme unchanged. This workaround applies only to version 3.0.0;
check startup logs again when updating the plugin input.

The SDK is linked at `~/Lib/Android/Sdk` for Android Studio and compatibility
with existing project paths. Add platforms and tools in `sdk.nix` and rebuild
instead of installing them in SDK Manager. Emulator images, NDK, and Android
CMake are intentionally omitted. Android Studio's SDK installation wizard is
disabled because the SDK is already provided by Nix. Activation also registers
this path in Android Studio's SDK settings.

The SDK is not installed in the user profile and does not add commands or
environment variables to the desktop session. Android Studio's launcher sets
`ANDROID_HOME` and `ANDROID_SDK_ROOT` explicitly, even when launched from a shell
containing another SDK. Android Studio and IDEA receive JDK 21 and `JAVA_HOME`
in their own launch environments; the IDEs still run on their upstream JBR.
CLion receives GCC, CMake, Ninja, and GDB in its private launch environment.
Desktop entries and terminal launchers use these same defaults. A project's
explicit Gradle JVM setting remains under that project's control.

Terminal builds use the project's own `nix develop` or direnv environment.
This module no longer provides `android-env`, a global JDK, or a global Gradle
JVM preference. It does not create project templates or edit project files.

On the first activation, a migration removes the old `org.gradle.java.home`
property only if its value exactly matches the JDK 21 path previously written
by this module. Other bytes and permissions are preserved; missing files and
user-managed symlinks are left alone. Completion is recorded in
`$XDG_STATE_HOME/jetbrains/migrations/gradle-java-home-v1`, so later manual
preferences are not removed. Home Manager also retires the old managed JDK
links under `~/Lib/jdks`. Existing Gradle caches are retained.

Configuration and cache directories are separate per IDE and major/minor
version under `~/.config/jetbrains` and `~/.cache/jetbrains`. Every Home Manager
activation restores True Black, the historical SpreadZhao editor color scheme,
and the Nix CLion toolchain. Other user state is preserved. Close IDEs before
applying changes so a running IDE cannot overwrite restored settings on exit.
The shared `.ideavimrc` remains editable in this repository; Quickscope stays
disabled as in its final historical version.
The IDE launchers set `QT_IM_MODULE=fcitx` and provide Fcitx's remote tool and
`busctl` for IdeaVimExtension's input-mode switching. These settings are scoped
to the IDEs and do not change the desktop session's input-method environment.

For local changes to both repositories, validate using
`--override-input personal-packages path:/home/spreadzhao/workspaces/nix-packages`
and `--no-write-lock-file`. Publish nix-packages before updating the permanent
personal-packages lock; do not commit an absolute local path in the lock file.
No repository command should activate a configuration automatically: the user
runs the switch after reviewing the build.
Start a new login session after applying the change: an existing process keeps
its inherited `JAVA_HOME`, `ANDROID_HOME`, and PATH values.
