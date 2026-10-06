{
  description = "Android development workspace";

  inputs = {
    spreadconfig.url = "github:SpreadZhao/spreadconfig";
    agent-workspace.follows = "spreadconfig/agent-workspace";
    nixpkgs.follows = "spreadconfig/nixpkgs";
    android-skills = {
      url = "github:android/skills";
      flake = false;
    };
  };

  outputs =
    {
      agent-workspace,
      android-skills,
      nixpkgs,
      spreadconfig,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      officialSkills = agent-workspace.lib.discoverSkills { source = android-skills; };
    in
    agent-workspace.lib.mkWorkspace {
      catalog = spreadconfig.lib.skillCatalog;
      inherit systems;
      skills = [ "android-dev" ];
      extraSkills = officialSkills;
      claude = false;
      packages =
        pkgs:
        with pkgs;
        lib.optionals (lib.meta.availableOn stdenv.hostPlatform android-cli) [ android-cli ]
        ++ [
          android-tools
          gradle
          jadx
          jdk17
          kotlin
          kotlin-language-server
          ktlint
          protobuf
          ripgrep
          scrcpy
        ];
      shellHook = ''
        android_sdk_default="''${ANDROID_HOME:-''${ANDROID_SDK_ROOT:-''${XDG_LIB_HOME:-$HOME/Lib}/Android/Sdk}}"
        export ANDROID_HOME="$android_sdk_default"
        export ANDROID_SDK_ROOT="$android_sdk_default"
        export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
        unset android_sdk_default

        if [ ! -d "$ANDROID_HOME" ]; then
          printf 'Android SDK directory not found: %s\n' "$ANDROID_HOME" >&2
          printf 'Install the SDK with Android Studio or set ANDROID_HOME before entering this shell.\n' >&2
        fi
      '';
    }
    // {
      formatter = lib.genAttrs systems (
        system:
        (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }).nixfmt
      );
    };
}
