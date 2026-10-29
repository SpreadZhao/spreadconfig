# shellcheck shell=bash
# Sourced by the CLI wrapper so PATH and positional arguments reach the executable.
profile_bin="${CODEX_CLI_PATH%/*}"
case "${PATH:-}" in
"$profile_bin" | "$profile_bin":*) ;;
*) export PATH="$profile_bin${PATH:+:$PATH}" ;;
esac
set -- -c "shell_environment_policy.set.PATH=$PATH" "$@"
