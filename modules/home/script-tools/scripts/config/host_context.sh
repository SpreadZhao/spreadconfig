#!/usr/bin/env bash

# Shared initialization for installed symlinks and checkout scripts.
spreadconfig_find_repo_root() {
	local source_file checkout
	source_file=$(readlink -f "${BASH_SOURCE[0]}") || return 1
	checkout=$(dirname "$source_file")
	while [[ ! -f "$checkout/flake.nix" || ! -d "$checkout/hosts" ]]; do
		if [[ "$checkout" == / ]]; then
			printf 'spreadconfig: could not find checkout from %s\n' "$source_file" >&2
			return 1
		fi
		checkout=$(dirname "$checkout")
	done
	printf '%s\n' "$checkout"
}

SPREADCONFIG_SOURCE_ROOT=$(spreadconfig_find_repo_root) || return 1

# Home Manager writes shell-escaped constants here; explicit build overrides
# remain separate so the configured machine can also build another host.
spreadconfig_context_file="${XDG_CONFIG_HOME:-$HOME/.config}/spreadconfig/host.sh"
if [[ -r "$spreadconfig_context_file" ]]; then
	# shellcheck source=/dev/null
	source "$spreadconfig_context_file" || return 1
fi
unset spreadconfig_context_file

spreadconfig_resolve_host() {
	SPREADCONFIG_TARGET_REPO="${SPREADCONFIG_REPO:-${SPREADCONFIG_CONFIGURED_REPO:-$SPREADCONFIG_SOURCE_ROOT}}"
	SPREADCONFIG_TARGET_HOST="${SPREADCONFIG_HOST:-${SPREADCONFIG_CONFIGURED_HOST:-}}"
	if [[ -z "$SPREADCONFIG_TARGET_HOST" ]]; then
		SPREADCONFIG_TARGET_HOST=$(hostname -s) || return 1
	fi
	if [[ ! "$SPREADCONFIG_TARGET_HOST" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]] ||
		[[ ! -f "$SPREADCONFIG_TARGET_REPO/hosts/$SPREADCONFIG_TARGET_HOST/host.nix" ]]; then
		printf 'spreadconfig: unknown host %s in %s (expected hosts/<host>/host.nix)\n' \
			"$SPREADCONFIG_TARGET_HOST" "$SPREADCONFIG_TARGET_REPO" >&2
		return 1
	fi
	SPREADCONFIG_TARGET_REPO=$(cd "$SPREADCONFIG_TARGET_REPO" && pwd -P)
}
