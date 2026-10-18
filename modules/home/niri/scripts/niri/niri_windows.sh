#!/usr/bin/env bash

# Show apps in the output's active workspace, grouped by column. Hide a lone group.
USE_ALIAS=true

# Alias file: one app-id=label per line; blank lines and comments are ignored.
load_app_aliases() {
    local icon_config="$SCRIPT_HOME/niri/niri_app_alias"

    declare -gA APP_ICONS

    if [ "$USE_ALIAS" = "true" ] && [ -f "$icon_config" ]; then
        while IFS='=' read -r app icon; do
            [[ -z "$app" || "$app" =~ ^# ]] && continue
            APP_ICONS["$app"]="$icon"
        done < "$icon_config"
    fi
}

get_active_workspace_json() {
    local output_name="$1"
    niri msg -j workspaces | jq --arg out "$output_name" \
        '[.[] | select(.is_active == true and .output == $out)] | first'
}

extract_workspace_id() {
    jq -r '.id'
}

get_windows_for_workspace() {
    local workspace_id="$1"
    niri msg -j windows | jq --argjson wid "$workspace_id" \
        'map(select(.workspace_id == $wid))'
}

sort_windows_by_position() {
    jq 'sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])'
}

# Mark the focused window with '*'; bracket apps sharing a column.
build_display_list() {
    mapfile -t windows_array < <(jq -r '.[] | @base64')

    local last_col=""
    local group=()
    local display_list=()

    for window in "${windows_array[@]}"; do
        local w
        w=$(echo "$window" | base64 --decode)

        local app_id is_focused col display
        app_id=$(echo "$w" | jq -r '.app_id')
        is_focused=$(echo "$w" | jq -r '.is_focused')
        is_floating=$(echo "$w" | jq -r '.is_floating')
        col=$(echo "$w" | jq -r '.layout.pos_in_scrolling_layout[0]')

        if [[ "$is_floating" == "true" && "$is_focused" == "false" ]]; then
            continue
        fi

        if [ "$USE_ALIAS" = "true" ] && [[ -n "${APP_ICONS[$app_id]}" ]]; then
            display="${APP_ICONS[$app_id]}"
        else
            display="$app_id"
        fi

        [[ "$is_focused" == "true" ]] && display="*$display"

        if [ "$col" != "$last_col" ]; then
            if [ "${#group[@]}" -gt 1 ]; then
                display_list+=("[${group[*]}]")
            elif [ "${#group[@]}" -eq 1 ]; then
                display_list+=("${group[0]}")
            fi
            group=("$display")
            last_col="$col"
        else
            group+=("$display")
        fi
    done

    if [ "${#group[@]}" -gt 1 ]; then
        display_list+=("[${group[*]}]")
    elif [ "${#group[@]}" -eq 1 ]; then
        display_list+=("${group[0]}")
    fi

    echo "${display_list[*]}"
}

get_active_workspace_app_ids_sorted() {
    local output_name="${WAYBAR_OUTPUT_NAME:?WAYBAR_OUTPUT_NAME not set}"

    load_app_aliases

    local workspace_json
    workspace_json="$(get_active_workspace_json "$output_name")"
    [[ -z "$workspace_json" || "$workspace_json" = "null" ]] && return 1

    local workspace_id
    workspace_id="$(echo "$workspace_json" | extract_workspace_id)"
    [[ -z "$workspace_id" || "$workspace_id" = "null" ]] && return 1

    local windows_json
    windows_json="$(get_windows_for_workspace "$workspace_id")"
    [[ -z "$windows_json" || "$windows_json" = "[]" ]] && return 0

    local sorted_windows
    sorted_windows="$(echo "$windows_json" | sort_windows_by_position)"

    local display_list
    display_list="$(echo "$sorted_windows" | build_display_list)"

    read -r -a display_array <<< "$display_list"

    if [ "${#display_array[@]}" -le 1 ]; then
        return 0
    fi

    echo "${display_list}"
}

get_active_workspace_app_ids_sorted
