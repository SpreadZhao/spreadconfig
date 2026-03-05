#!/usr/bin/env bash
set -euo pipefail

TMP_INPUT=$(mktemp)
TMP_OUTPUT=$(mktemp)

trap 'rm -f "$TMP_INPUT" "$TMP_OUTPUT"' EXIT

cat > "$TMP_INPUT"

footclient \
    -a "lick-foot" \
    -T "dmenu" \
    -- sh -c '
        preview() {
            line="$1"

            # 提取 id（第一列）
            id=$(printf "%s\n" "$line" | awk "{print \$1}")

            # 判断是否 binary
            if printf "%s\n" "$line" | grep -q "binary"; then
                cliphist decode "$id" | chafa --size="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" -
            else
                cliphist decode "$id"
            fi
        }

        export -f preview

        fzf \
            --preview '\''bash -c "preview \"\$1\"" _ {}'\'' \
            < "'"$TMP_INPUT"'" \
            > "'"$TMP_OUTPUT"'"
    '

if [[ -s "$TMP_OUTPUT" ]]; then
    cat "$TMP_OUTPUT"
fi
