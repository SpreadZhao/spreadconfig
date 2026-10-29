#!/usr/bin/env bash

output=$1
mkdir -p "$output/bin" "$output/share/applications" "$output/share/icons"
cp -rs "$DESKTOP_PACKAGE/share/icons/." "$output/share/icons/"

for profile_definition in "${PROFILE_DEFINITIONS[@]}"; do
    # shellcheck source=/dev/null
    source "$profile_definition"
    app_id="codex-desktop-$PROFILE_NAME"
    private_bin="$output/libexec/$PROFILE_NAME/bin"
    mkdir -p "$private_bin"
    profile_flags=(
        --set CODEX_HOME "$PROFILE_ROOT/codex"
        --unset CODEX_SQLITE_HOME
        --set CODEX_CLI_PATH "$private_bin/codex"
        --unset CODEX_LINUX_APP_SERVER_BRIDGE_SOCKET
        --unset CODEX_REMOTE_CONTROL_APP_SERVER_PROXY_SOCKET
        --run "$PROFILE_SETUP"
    )

    # Preserve the selected profile when Desktop starts a CLI with a filtered environment.
    makeWrapper "$CODEX_RESOURCES/codex" "$private_bin/codex" \
        "${profile_flags[@]}" \
        --prefix PATH : "$output/bin" \
        --suffix PATH : "$BUBBLEWRAP_PATH" \
        --run "source \"$CLI_ENVIRONMENT_SCRIPT\""

    # Completion notifications include the response; approvals keep terminal alerts.
    makeWrapper "$private_bin/codex" "$output/bin/codex-$PROFILE_NAME" \
        --add-flags "$PROFILE_CLI_FLAGS"

    # Keep browser helpers on the selected Desktop package's runtime.
    makeWrapper "$CODEX_RESOURCES/cua_node/bin/node_repl" "$output/bin/codex-node-repl-$PROFILE_NAME" \
        "${profile_flags[@]}" \
        "${ENVIRONMENT_FLAGS[@]}" \
        --set NODE_REPL_NATIVE_PIPE_CONNECT_TIMEOUT_MS '1000' \
        --set NODE_REPL_NODE_MODULE_DIRS "$CODEX_RESOURCES/cua_node/lib/node_modules" \
        --set NODE_REPL_NODE_PATH "$CODEX_RESOURCES/cua_node/bin/node" \
        --set NODE_REPL_TRUSTED_CODE_PATHS "$PROFILE_ROOT/codex:$CODEX_RESOURCES/cua_node/lib/node_modules:$CODEX_RESOURCES/plugins/openai-bundled/plugins/browser/scripts" \
        --set NODE_REPL_TRUSTED_SERVICES "$PROFILE_TRUSTED_SERVICES" \
        --set BROWSER_USE_AVAILABLE_BACKENDS 'chrome,iab,mcpapps' \
        --set BROWSER_USE_TINYSKY_ENABLED '1' \
        --set NODE_REPL_INSTRUCTIONS_USE_CASE_BROWSER "" \
        --set NODE_REPL_INSTRUCTIONS_USE_CASE_CHROME "" \
        --set BROWSER_USE_CODEX_APP_BUILD_FLAVOR 'prod' \
        --set BROWSER_USE_CODEX_APP_VERSION "$DESKTOP_VERSION"

    makeWrapper "$DESKTOP_PACKAGE/bin/codex-desktop" "$output/bin/$app_id" \
        "${profile_flags[@]}" \
        --prefix PATH : "$private_bin" \
        --set NIXOS_OZONE_WL '1' \
        --set CODEX_LINUX_APP_ID "$app_id" \
        --set CODEX_LINUX_APP_DISPLAY_NAME "Codex — $PROFILE_NAME" \
        --set CODEX_ELECTRON_USER_DATA_PATH "$PROFILE_ROOT/config/Codex-Community" \
        --set CHROME_DESKTOP "$PROFILE_DESKTOP_ID.desktop" \
        --set BAMF_DESKTOP_FILE_HINT "$output/share/applications/$PROFILE_DESKTOP_ID.desktop" \
        "${ENVIRONMENT_FLAGS[@]}" \
        --append-flags "$PROFILE_DESKTOP_FLAGS"

    cp "$PROFILE_DESKTOP_FILE" "$output/share/applications/"
    substituteInPlace "$output/share/applications/$PROFILE_DESKTOP_ID.desktop" \
        --replace-fail "Exec=$app_id" "Exec=$output/bin/$app_id"
done
ln -s codex-desktop-spreadzhao "$output/bin/codex-desktop"

export CODEX_HOME="$TMPDIR/completion-home"
mkdir -p "$CODEX_HOME"
"$CODEX_RESOURCES/codex" completion zsh >"$TMPDIR/_codex"
substituteInPlace "$TMPDIR/_codex" \
    --replace-fail '#compdef codex' '#compdef codex-spreadzhao codex-supazodiac' \
    --replace-fail 'compdef _codex codex' 'compdef _codex codex-spreadzhao codex-supazodiac'
installShellCompletion --zsh "$TMPDIR/_codex"
