{
  description = "Android development environment";

  inputs = {
    android-skills = {
      url = "github:android/skills";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      android-skills,
      nixpkgs,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkInstallAndroidSkills =
        pkgs:
        pkgs.writeShellApplication {
          name = "install-android-skills";
          runtimeInputs = with pkgs; [
            coreutils
            findutils
            gawk
          ];
          text = ''
            set -euo pipefail

            root="''${1:-$PWD}"
            skills_root="$root/.agents/skills"
            android_skills_source="${android-skills}"
            managed_manifest="$skills_root/.android-skills-managed"

            install_skill() {
              local target_name="$1"
              local source="$2"
              local target="$skills_root/$target_name"
              local current=""

              if [ ! -d "$source" ]; then
                echo "Skill source does not exist: $source" >&2
                return 1
              fi

              if [ ! -f "$source/SKILL.md" ]; then
                echo "Skill source is missing SKILL.md: $source" >&2
                return 1
              fi

              if [ -e "$target" ] || [ -L "$target" ]; then
                current="$(readlink "$target" || true)"
                if [ "$current" = "$source" ]; then
                  return 0
                fi

                if [ -L "$target" ] && { [[ "$current" == /nix/store/* ]] || [[ "$current" == "$root"/skills/local/* ]]; }; then
                  rm -f "$target"
                else
                  echo "Skill target already exists and is not managed: $target" >&2
                  return 1
                fi
              fi

              mkdir -p "$(dirname "$target")"
              ln -s "$source" "$target"
            }

            is_managed_target() {
              local target="$1"
              local current=""

              if [ ! -L "$target" ]; then
                return 1
              fi

              current="$(readlink "$target" || true)"
              [[ "$current" == /nix/store/* ]] || [[ "$current" == "$root"/skills/local/* ]]
            }

            prune_old_official_skills() {
              local target_name=""
              local target=""

              if [ ! -f "$managed_manifest" ]; then
                return 0
              fi

              while IFS= read -r target_name; do
                if [ -z "$target_name" ]; then
                  continue
                fi

                case "$target_name" in
                  .* | */* | *[!A-Za-z0-9._-]*)
                    echo "Skipping unsafe managed skill name: $target_name" >&2
                    continue
                    ;;
                esac

                target="$skills_root/$target_name"
                if is_managed_target "$target"; then
                  rm -f "$target"
                fi
              done < "$managed_manifest"
            }

            read_skill_name() {
              local skill_file="$1"

              awk '
                NR == 1 && $0 == "---" {
                  in_frontmatter = 1
                  next
                }
                in_frontmatter && $0 == "---" {
                  exit
                }
                in_frontmatter && $0 ~ /^name:[[:space:]]*/ {
                  sub(/^name:[[:space:]]*/, "")
                  print
                  exit
                }
              ' "$skill_file"
            }

            install_official_skills() {
              local next_manifest=""
              local skill_file=""
              local skill_dir=""
              local skill_name=""

              next_manifest="$(mktemp "''${TMPDIR:-/tmp}/android-skills-managed.XXXXXX")"
              while IFS= read -r skill_file; do
                skill_dir="$(dirname "$skill_file")"
                skill_name="$(read_skill_name "$skill_file")"

                case "$skill_name" in
                  "" | .* | */* | *[!A-Za-z0-9._-]*)
                    echo "Could not determine safe skill name for $skill_file: $skill_name" >&2
                    rm -f "$next_manifest"
                    return 1
                    ;;
                esac

                install_skill "$skill_name" "$skill_dir"
                printf '%s\n' "$skill_name" >> "$next_manifest"
              done < <(find "$android_skills_source" -type f -name SKILL.md | sort)

              mv "$next_manifest" "$managed_manifest"
            }

            mkdir -p "$skills_root"
            prune_old_official_skills
            install_skill android-dev "$root/skills/local/android-dev"
            install_official_skills
            echo "Android skills installed into $skills_root"
          '';
        };
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          installAndroidSkills = mkInstallAndroidSkills pkgs;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              android-cli
              android-tools
              gradle
              installAndroidSkills
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

              if [ ! -d "$ANDROID_HOME" ]; then
                printf 'Android SDK directory not found: %s\n' "$ANDROID_HOME" >&2
                printf 'Install the SDK with Android Studio or set ANDROID_HOME before entering this shell.\n' >&2
              fi

              ${installAndroidSkills}/bin/install-android-skills "$PWD"
            '';
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          install-android-skills = mkInstallAndroidSkills pkgs;
        }
      );

      apps = forAllSystems (
        system:
        let
          installAndroidSkills = mkInstallAndroidSkills (mkPkgs system);
        in
        {
          install-android-skills = {
            type = "app";
            program = "${installAndroidSkills}/bin/install-android-skills";
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.nixfmt-rfc-style
      );
    };
}
