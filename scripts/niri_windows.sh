#!/usr/bin/bash

# This script displays the sorted list of app IDs (or aliases/icons)
# for all windows in the currently active workspace on a given output (monitor)
# managed by the "niri" compositor.
#
# Windows are grouped by column and sorted by their position in the layout.
# If there is only one resulting group (or one window), nothing will be printed.

USE_ALIAS=true

# -----------------------------
# Utility: Load app aliases
# -----------------------------
# Reads alias/icon mappings from a config file and populates an associative array.
# File format (example):
#   firefox=
#   foot=
#   # lines starting with '#' are ignored
#
# Globals:
#   HOME, APP_ICONS
# Arguments:
#   None
# Returns:
#   None (populates APP_ICONS)
load_app_aliases() {
    local icon_config="${HOME}/scripts/niri_app_alias"

    declare -gA APP_ICONS  # global associative array

    if [ "$USE_ALIAS" = "true" ] && [ -f "$icon_config" ]; then
        while IFS='=' read -r app icon; do
            [[ -z "$app" || "$app" =~ ^# ]] && continue
            APP_ICONS["$app"]="$icon"
        done < "$icon_config"
    fi
}

# -----------------------------
# Get the active workspace JSON for a specific output
# -----------------------------
# Uses `niri msg -j workspaces` and filters the one that is both
# active and assigned to the given output.
#
# Arguments:
#   $1 - output name (e.g., HDMI-A-1)
# Outputs:
#   The full workspace JSON object, or empty if not found
get_active_workspace_json() {
    local output_name="$1"
    niri msg -j workspaces | jq --arg out "$output_name" \
        '[.[] | select(.is_active == true and .output == $out)] | first'
}

# -----------------------------
# Extract workspace ID from workspace JSON
# -----------------------------
# Arguments:
#   None (reads from stdin)
# Outputs:
#   The workspace ID string, or empty if not found
extract_workspace_id() {
    jq -r '.id'
}

# -----------------------------
# Get windows belonging to a workspace
# -----------------------------
# Uses `niri msg -j windows` and filters only windows with the given workspace ID.
#
# Arguments:
#   $1 - workspace ID
# Outputs:
#   JSON array of windows belonging to that workspace
get_windows_for_workspace() {
    local workspace_id="$1"
    niri msg -j windows | jq --argjson wid "$workspace_id" \
        'map(select(.workspace_id == $wid))'
}

# -----------------------------
# Sort windows by position in layout
# -----------------------------
# Sorts JSON array of windows by their X/Y position in the scrolling layout.
#
# Arguments:
#   None (reads from stdin)
# Outputs:
#   Sorted JSON array
sort_windows_by_position() {
    jq 'sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])'
}

# -----------------------------
# Convert sorted windows JSON into display list
# -----------------------------
# Groups windows by column. Each column may contain multiple apps,
# represented as "[A B C]". Focused windows are prefixed with '*'.
# Uses aliases/icons if available.
#
# Globals:
#   APP_ICONS, USE_ALIAS
# Arguments:
#   None (reads JSON array from stdin)
# Outputs:
#   Bash array (echoed as a space-separated string)
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

        # Skip floating but unfocused windows
        if [[ "$is_floating" == "true" && "$is_focused" == "false" ]]; then
            continue
        fi

        # Use alias/icon if available
        if [ "$USE_ALIAS" = "true" ] && [[ -n "${APP_ICONS[$app_id]}" ]]; then
            display="${APP_ICONS[$app_id]}"
        else
            display="$app_id"
        fi

        # Highlight focused window
        [[ "$is_focused" == "true" ]] && display="*$display"

        # Group by column
        if [ "$col" != "$last_col" ]; then
            # Push previous group
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

    # Push the last group
    if [ "${#group[@]}" -gt 1 ]; then
        display_list+=("[${group[*]}]")
    elif [ "${#group[@]}" -eq 1 ]; then
        display_list+=("${group[0]}")
    fi

    echo "${display_list[*]}"
}

# -----------------------------
# Main function
# -----------------------------
# Coordinates the logic:
#   1. Load aliases (if enabled)
#   2. Get active workspace for the target output
#   3. Collect and sort windows
#   4. Build display list
#   5. Print result (unless only one element)
#
# Globals:
#   WAYBAR_OUTPUT_NAME (must be set)
# Returns:
#   0 (success), prints nothing if only one window/group
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

    # Split display list into array to count elements
    read -r -a display_array <<< "$display_list"

    # Do not output if there is only one window/group
    if [ "${#display_array[@]}" -le 1 ]; then
        return 0
    fi

    echo "${display_list}"
}

# -----------------------------
# Entry point
# -----------------------------
get_active_workspace_app_ids_sorted
