#!/bin/bash

# ===========================
# Configurations
# ===========================

MAX_LEN=30              # Max length for name part
TRUNCATE_MODE="both"    # Options: head | tail | both

# ===========================
# Functions
# ===========================

# Get the focused window title line: "name [bracket]"
get_title() {
    swaymsg -t get_tree | jq -r '
      .. | select(.type?) | select(.focused == true) |
      "\(.name) [\(.app_id // .window_properties.instance // .window_properties.class)]"
    '
}

# Return true if string is blank (empty or only whitespace)
is_blank() {
    [[ -z "${1//[[:space:]]/}" ]]
}

# Return true if string is "number [null-like]" (looser detection)
is_number_null_like() {
    local s="$1"
    if [[ "$s" =~ ^[[:space:]]*[0-9]+[[:space:]]*\[[[:space:]]*([Nn][Uu][Ll][Ll]|[Nn][Oo][Nn][Ee]|[Nn][Ii][Ll]|[Uu][Nn][Dd][Ee][Ff][Ii][Nn][Ee][Dd]|[Ee][Mm][Pp][Tt][Yy])[[:space:]]*\][[:space:]]*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Trim leading and trailing whitespace (pure bash)
trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Keep everything before the LAST dash (supports -, ‐, –, —)
strip_after_last_dash() {
    local s="$1"
    if [[ "$s" != *[-‐–—]* ]]; then
        printf '%s' "$s"
        return
    fi
    printf '%s' "$s" | sed -E 's/^(.*)[[:space:]]*[-‐–—][[:space:]]*.*$/\1/'
}

# Truncate string according to TRUNCATE_MODE
truncate_if_needed() {
    local s="$1"
    local len=${#s}

    if (( len <= MAX_LEN )); then
        printf '%s' "$s"
        return
    fi

    case "$TRUNCATE_MODE" in
        head)
            printf '%s…' "${s:0:MAX_LEN}"
            ;;
        tail)
            printf '…%s' "${s: -MAX_LEN}"
            ;;
        both)
            # Reserve space for ellipsis
            local half=$(( (MAX_LEN - 1) / 2 ))
            local head_part="${s:0:half}"
            local tail_part="${s: -half}"
            printf '%s…%s' "$head_part" "$tail_part"
            ;;
        *)
            printf '%s…' "${s:0:MAX_LEN}"  # fallback to head mode
            ;;
    esac
}

# ===========================
# Main
# ===========================

main() {
    local title
    title=$(get_title)

    if is_blank "$title"; then
        exit 0
    fi

    if is_number_null_like "$title"; then
        exit 0
    fi

    if [[ "$title" =~ ^(.*)\ \[(.*)\]$ ]]; then
        local name_part="${BASH_REMATCH[1]}"
        local bracket_part="${BASH_REMATCH[2]}"

        name_part=$(trim "$name_part")
        name_part=$(strip_after_last_dash "$name_part")
        name_part=$(trim "$name_part")
        name_part=$(truncate_if_needed "$name_part")

        echo " $name_part [$bracket_part]"
    else
        echo " $title"
    fi
}

main "$@"
