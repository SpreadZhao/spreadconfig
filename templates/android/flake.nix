{
  description = "Android development workspace";

  inputs = {
    spreadconfig.url = "github:SpreadZhao/spreadconfig";
    nixpkgs.follows = "spreadconfig/nixpkgs";
    android-skills = {
      url = "github:android/skills";
      flake = false;
    };
  };

  outputs =
    {
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
      findSkills =
        directory:
        let
          entries = builtins.readDir directory;
        in
        lib.concatMap (
          name:
          let
            path = directory + "/${name}";
          in
          if entries.${name} == "directory" then
            findSkills path
          else
            lib.optional (name == "SKILL.md" && entries.${name} == "regular") path
        ) (builtins.attrNames entries);
      skillEntry =
        file:
        let
          lines = lib.splitString "\n" (lib.replaceStrings [ "\r" ] [ "" ] (builtins.readFile file));
          readHeader =
            remaining:
            if remaining == [ ] then
              throw "Unterminated skill frontmatter in ${file}"
            else if builtins.head remaining == "---" then
              [ ]
            else
              [ (builtins.head remaining) ] ++ readHeader (builtins.tail remaining);
          header = readHeader (builtins.tail lines);
          names = lib.filter (value: value != null) (
            map (
              line: builtins.match "name:[[:space:]]*['\"]?([a-zA-Z0-9][a-zA-Z0-9._-]*)['\"]?[[:space:]]*" line
            ) header
          );
        in
        assert lib.assertMsg (
          builtins.head lines == "---" && builtins.length names == 1
        ) "Cannot read a safe skill name from ${file}";
        {
          name = builtins.head (builtins.head names);
          value = builtins.dirOf file;
        };
      officialEntries = map skillEntry (findSkills android-skills.outPath);
      officialSkills =
        assert lib.assertMsg (
          builtins.length officialEntries
          == builtins.length (lib.unique (map (entry: entry.name) officialEntries))
        ) "Duplicate names in the Android skills input";
        builtins.listToAttrs officialEntries;
    in
    spreadconfig.lib.mkWorkspace {
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
