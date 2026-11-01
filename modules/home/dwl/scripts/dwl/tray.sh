#!/usr/bin/env bash
set -euo pipefail

watcher_service="org.kde.StatusNotifierWatcher"
watcher_path="/StatusNotifierWatcher"
watcher_interface="org.kde.StatusNotifierWatcher"
item_interface="org.kde.StatusNotifierItem"
menu_interface="com.canonical.dbusmenu"

clean_filter='
def clean_text:
    gsub("[\u0000-\u001f\u007f-\u009f\r\n\t]+"; " ")
    | sub("^ +"; "")
    | sub(" +$"; "");
def strip_mnemonic:
    gsub("__"; "\u0000")
    | gsub("_"; "")
    | gsub("\u0000"; "_")
    | clean_text;
'

activate_item() {
	local dest="$1" path="$2"
	busctl --user call -- "$dest" "$path" "$item_interface" Activate ii 0 0 >/dev/null 2>&1 ||
		busctl --user call -- "$dest" "$path" "$item_interface" ContextMenu ii 0 0 >/dev/null 2>&1 ||
		busctl --user call -- "$dest" "$path" "org.freedesktop.StatusNotifierItem" Activate ii 0 0 >/dev/null 2>&1
}

get_prop_fallback() {
	local dest="$1" path="$2" prop="$3"
	busctl --user --json=short get-property -- "$dest" "$path" "$item_interface" "$prop" 2>/dev/null ||
		printf 'null\n'
}

items_json="$(
	busctl --user --json=short get-property -- \
		"$watcher_service" "$watcher_path" "$watcher_interface" RegisteredStatusNotifierItems 2>/dev/null || true
)"

mapfile -t raw_items < <(
	if [[ -n "$items_json" ]]; then
		jq -r '.data[]? // empty' <<<"$items_json"
	fi
)

if [[ ${#raw_items[@]} -eq 0 ]]; then
	notify-send --app-name "tray" "System tray" "No tray items registered."
	exit 0
fi

declare -a item_dests=()
declare -a item_paths=()
declare -a item_titles=()
declare -a item_labels=()
declare -a item_menus=()
declare -a item_is_menus=()

for entry in "${raw_items[@]}"; do
	[[ "$entry" == */* ]] || continue
	dest="${entry%%/*}"
	path="/${entry#*/}"
	[[ -n "$dest" ]] || continue

	props_json="$(
		busctl --user --json=short call -- "$dest" "$path" \
			org.freedesktop.DBus.Properties GetAll s "$item_interface" 2>/dev/null || true
	)"

	if [[ -z "$props_json" ]] || [[ "$(jq -r '.data[0] | length // 0' <<<"$props_json" 2>/dev/null || printf '0')" -eq 0 ]]; then
		title_json="$(get_prop_fallback "$dest" "$path" Title)"
		id_json="$(get_prop_fallback "$dest" "$path" Id)"
		menu_json="$(get_prop_fallback "$dest" "$path" Menu)"
		is_menu_json="$(get_prop_fallback "$dest" "$path" ItemIsMenu)"
		props_json="$(
			jq -n \
				--argjson title "$title_json" \
				--argjson id "$id_json" \
				--argjson menu "$menu_json" \
				--argjson is_menu "$is_menu_json" \
				'{data: [{
                    Title: ($title // {}),
                    Id: ($id // {}),
                    Menu: ($menu // {}),
                    ItemIsMenu: ($is_menu // {})
                }]}'
		)"
	fi

	parsed="$(
		jq -r --arg dest "$dest" "$clean_filter"'
            (.data[0] // {}) as $p
            | ($p.Title.data // "" | if type == "string" then clean_text else "" end) as $title
            | ($p.Id.data // "" | if type == "string" then clean_text else "" end) as $id
            | ($p.ToolTip.data // null
                | if (type == "array" and (.[2] | type) == "string") then (.[2] | clean_text) else "" end) as $tip
            | (if $title != "" then $title elif $id != "" then $id else $dest end) as $name
            | (if ($tip != "" and $tip != $name) then "\($name) (\($tip))" else $name end) as $label
            | ($p.Menu.data // "" | if type == "string" then . else "" end) as $menu
            | (if ($p.ItemIsMenu.data // false) == true then "true" else "false" end) as $is_menu
            | [$name, $label, $menu, $is_menu]
            | @tsv
        ' <<<"$props_json" 2>/dev/null || true
	)"

	[[ -n "$parsed" ]] || continue
	IFS=$'\t' read -r app_title app_label menu_path is_menu <<<"$parsed"

	item_dests+=("$dest")
	item_paths+=("$path")
	item_titles+=("$app_title")
	item_labels+=("$app_label")
	item_menus+=("$menu_path")
	item_is_menus+=("$is_menu")
done

if [[ ${#item_labels[@]} -eq 0 ]]; then
	notify-send --app-name "tray" "System tray" "No active tray items found."
	exit 0
fi

selected_idx="$(
	printf '%s\n' "${item_labels[@]}" |
		fuzzel --dmenu --index --prompt "Tray: " || true
)"

[[ "$selected_idx" =~ ^[0-9]+$ ]] || exit 0
((selected_idx < ${#item_dests[@]})) || exit 0

dest="${item_dests[$selected_idx]}"
item_path="${item_paths[$selected_idx]}"
app_title="${item_titles[$selected_idx]}"
menu_path="${item_menus[$selected_idx]}"
is_menu="${item_is_menus[$selected_idx]}"

declare -a action_ids=()
declare -a action_labels=()

if [[ "$is_menu" != "true" ]]; then
	action_ids+=("activate")
	action_labels+=("Activate window")
fi

if [[ -n "$menu_path" && "$menu_path" != "/" ]]; then
	busctl --user call -- "$dest" "$menu_path" "$menu_interface" AboutToShow i 0 >/dev/null 2>&1 || true
	layout_json="$(
		busctl --user --json=short call -- "$dest" "$menu_path" \
			"$menu_interface" GetLayout iias 0 -1 0 2>/dev/null || true
	)"

	if [[ -n "$layout_json" ]]; then
		while IFS=$'\t' read -r menu_id menu_label; do
			[[ -n "$menu_id" && -n "$menu_label" ]] || continue
			action_ids+=("$menu_id")
			action_labels+=("$menu_label")
		done < <(
			jq -r "$clean_filter"'
                def walk_menu($prefix):
                    . as $node
                    | ($node[0]) as $id
                    | ($node[1] // {}) as $props
                    | ([ $node[2][]? | .data ]) as $children
                    | if ($props.visible.data // true) == false then empty
                      elif ($props.enabled.data // true) == false then empty
                      elif ($props.type.data // "standard") == "separator" then empty
                      else
                          ($props.label.data // "" | if type == "string" then strip_mnemonic else "" end) as $label
                          | (if ($props["toggle-type"].data // "") == "radio" then
                                if ($props["toggle-state"].data // 0) == 1 then "(•) " else "( ) " end
                             elif ($props["toggle-type"].data // "") == "checkmark" then
                                if ($props["toggle-state"].data // 0) == 1 then "[✓] " else "[ ] " end
                             else "" end) as $toggle
                          | (if $prefix == "" then $label
                             elif $label == "" then $prefix
                             else "\($prefix) › \($label)" end) as $next_prefix
                          | if (($props["children-display"].data // "") == "submenu") or (($children | length) > 0) then
                                $children[] | walk_menu($next_prefix)
                            elif $label != "" then
                                "\($id)\t\($prefix | if . == "" then "" else "\(.) › " end)\($toggle)\($label)"
                            else
                                empty
                            end
                      end;
                (.data[1][2] // [])[]
                | .data
                | walk_menu("")
            ' <<<"$layout_json" 2>/dev/null || true
		)
	fi
fi

if [[ ${#action_ids[@]} -eq 0 ]]; then
	activate_item "$dest" "$item_path"
	exit 0
fi

action_idx="$(
	printf '%s\n' "${action_labels[@]}" |
		fuzzel --dmenu --index --prompt "${app_title}: " || true
)"

[[ "$action_idx" =~ ^[0-9]+$ ]] || exit 0
((action_idx < ${#action_ids[@]})) || exit 0

chosen_action="${action_ids[$action_idx]}"
if [[ "$chosen_action" == "activate" ]]; then
	activate_item "$dest" "$item_path"
else
	busctl --user call -- "$dest" "$menu_path" "$menu_interface" \
		Event isvu "$chosen_action" clicked i 0 0 >/dev/null
fi
