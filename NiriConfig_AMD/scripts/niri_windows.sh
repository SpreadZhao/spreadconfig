#!/usr/bin/bash

USE_ALIAS=true

get_active_workspace_app_ids_sorted() {
    local use_alias="${USE_ALIAS}"
    local output_name="${WAYBAR_OUTPUT_NAME:?WAYBAR_OUTPUT_NAME not set}"
    local icon_config="${HOME}/scripts/niri_app_alias"

    # 如果启用 icon，加载映射
    declare -A APP_ICONS
    if [ "$use_alias" = "true" ] && [ -f "$icon_config" ]; then
        while IFS='=' read -r app icon; do
            [[ -z "$app" || "$app" =~ ^# ]] && continue
            APP_ICONS["$app"]="$icon"
        done < "$icon_config"
    fi

    # Step 1: 获取目标输出的活跃 workspace
    local workspace_json
    workspace_json="$(niri msg -j workspaces | jq --arg out "$output_name" '[.[] | select(.is_active == true and .output == $out)] | first')"
    [[ -z "$workspace_json" || "$workspace_json" = "null" ]] && echo "" && return 1

    local workspace_id
    workspace_id="$(echo "$workspace_json" | jq -r '.id')"
    [[ -z "$workspace_id" || "$workspace_id" = "null" ]] && echo "" && return 1

    # Step 2: 获取所有窗口
    local windows_json
    windows_json="$(niri msg -j windows)"

    # Step 3: 过滤属于目标 workspace 的窗口
    local filtered_windows
    filtered_windows="$(echo "$windows_json" | jq --argjson wid "$workspace_id" 'map(select(.workspace_id == $wid))')"

    # Step 4: 按 layout.pos_in_scrolling_layout 排序
    local sorted_windows
    sorted_windows="$(echo "$filtered_windows" | jq 'sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])')"

    echo "$sorted_windows" | jq -r '.[] | @base64' | while read -r window; do
        w=$(echo "$window" | base64 --decode)
        app_id=$(echo "$w" | jq -r '.app_id')
        is_focused=$(echo "$w" | jq -r '.is_focused')

        # 根据参数决定显示内容
        if [ "$use_alias" = "true" ] && [[ -n "${APP_ICONS[$app_id]}" ]]; then
            display="${APP_ICONS[$app_id]}"
        else
            display="$app_id"
        fi

        # 如果 focused，前面加 *
        [[ "$is_focused" == "true" ]] && display="*$display"

        echo -n "$display "
    done
    echo
}
get_active_workspace_windows_json() {
    local output_name="${WAYBAR_OUTPUT_NAME:?WAYBAR_OUTPUT_NAME not set}"

    # Step 1: Get the active workspace for the target output
    local workspace_json
    workspace_json="$(niri msg -j workspaces | jq --arg out "$output_name" '[.[] | select(.is_active == true and .output == $out)] | first')"
    if [ -z "$workspace_json" ] || [ "$workspace_json" = "null" ]; then
        return 1
    fi

    # Extract workspace_id
    local workspace_id
    workspace_id="$(echo "$workspace_json" | jq -r '.id')"
    if [ -z "$workspace_id" ] || [ "$workspace_id" = "null" ]; then
        return 1
    fi

    # Step 2: Get all windows
    local windows_json
    windows_json="$(niri msg -j windows)"

    # Step 3: Filter windows belonging to the target workspace
    local filtered_windows
    filtered_windows="$(echo "$windows_json" | jq --argjson wid "$workspace_id" 'map(select(.workspace_id == $wid))')"

    # Step 4: Sort windows by layout.pos_in_scrolling_layout
    local sorted_windows
    sorted_windows="$(echo "$filtered_windows" | jq '
        sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])
    ')"

    # Step 5: Output each window as a JSON object
    echo "$sorted_windows" | jq -c '.[] | {text: .app_id, class: (if .is_focused then "focused" else "unfocused" end)}'
}
niri msg event-stream | while read -r line; do
    get_active_workspace_app_ids_sorted
done
