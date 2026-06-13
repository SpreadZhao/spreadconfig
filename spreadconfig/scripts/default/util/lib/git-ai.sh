#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "git-ai.sh is a shared library and should be sourced." >&2
    exit 1
fi

GIT_AI_LIB_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
GIT_AI_LIB_DIR="$(cd -- "$(dirname -- "$GIT_AI_LIB_PATH")" && pwd -P)"
# shellcheck source=spreadconfig/scripts/default/util/config/git-ai.sh
source "$GIT_AI_LIB_DIR/../config/git-ai.sh"

git_ai_backend_description() {
    case "$GIT_AI_AGENT" in
    codex)
        printf 'Codex (%s, %s)' "$GIT_AI_CODEX_MODEL" "$GIT_AI_CODEX_REASONING_EFFORT"
        ;;
    claude)
        printf 'Claude Code (%s, %s)' "$GIT_AI_CLAUDE_MODEL" "$GIT_AI_CLAUDE_EFFORT"
        ;;
    *)
        printf '%s' "$GIT_AI_AGENT"
        ;;
    esac
}

git_ai_run() {
    local prompt="$1"
    local context_file="$2"
    local output_file="$3"
    local log_file="$4"

    case "$GIT_AI_AGENT" in
    codex)
        local -a args=(
            exec
            --model "$GIT_AI_CODEX_MODEL"
            --config "model_reasoning_effort=\"$GIT_AI_CODEX_REASONING_EFFORT\""
            --sandbox "$GIT_AI_CODEX_SANDBOX"
        )

        if [[ "$GIT_AI_CODEX_EPHEMERAL" == "1" || "$GIT_AI_CODEX_EPHEMERAL" == "true" ]]; then
            args+=(--ephemeral)
        fi

        args+=(
            --output-last-message "$output_file"
            "$prompt"
        )

        codex "${args[@]}" <"$context_file" >"$log_file" 2>&1
        ;;
    claude)
        local -a args=(
            -p
            --model "$GIT_AI_CLAUDE_MODEL"
            --effort "$GIT_AI_CLAUDE_EFFORT"
            --output-format text
            "$prompt"
        )

        claude "${args[@]}" <"$context_file" >"$output_file" 2>"$log_file"
        ;;
    *)
        echo "Unsupported git AI agent: $GIT_AI_AGENT" >&2
        echo "Currently supported agents: codex, claude" >&2
        return 2
        ;;
    esac
}
