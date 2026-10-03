#!/usr/bin/env bash

########################################
# 读取所有 desktop entry
########################################
get_desktop_entries() {
    printf "%s\n" \
        /usr/share/applications/*.desktop \
        ~/.local/share/applications/*.desktop 2>/dev/null
}

########################################
# 从 desktop entry 提取 Exec 行并清洗参数
########################################
get_exec_cmd() {
    local desktop="$1"

    local file=""
    if [[ -f "$HOME/.local/share/applications/$desktop" ]]; then
        file="$HOME/.local/share/applications/$desktop"
    elif [[ -f "/usr/share/applications/$desktop" ]]; then
        file="/usr/share/applications/$desktop"
    else
        echo ""
        return
    fi

    local exec_line
    exec_line=$(grep -E '^Exec=' "$file" | head -n1 | sed 's/^Exec=//')

    # 清除掉 %u %U %f %F 等
    exec_line=$(sed 's/ *%[uUfF]//g' <<< "$exec_line")

    echo "$exec_line"
}

########################################
# 启动 niri 监听脚本（等待窗口创建）
########################################
wait_for_window() {
    local target="$1"
    local cnt=0

    # echo "等待窗口: $target"

    (
        niri msg event-stream | while IFS= read -r line; do
            if [[ "$line" == *"Window opened"* && "$line" == *"$target"* ]]; then
                # echo "捕获到了窗口 $target"
                niri msg action consume-or-expel-window-left
                break
            fi
            #
            # ((cnt++))
            # ((cnt >= 20)) && echo "cnt over" && break
        done
    ) &
}

########################################
# 构建 wofi 列表并选择 desktop entry
########################################
choose_desktop() {
    local entries list=""

    entries=$(get_desktop_entries)
    for f in $entries; do
        [[ ! -f "$f" ]] && continue
        name=$(grep -E '^Name=' "$f" | head -n1 | cut -d= -f2-)
        [[ -z "$name" ]] && continue
        base=$(basename "$f")
        list+="$name || $base"$'\n'
    done

    printf "%s" "$list" | wofi --dmenu
}

########################################
# 主流程
########################################

chosen=$(choose_desktop)
[[ -z "$chosen" ]] && exit 0

desktop=$(sed 's/.* || //' <<< "$chosen")

# 解析 Exec 命令
exec_cmd=$(get_exec_cmd "$desktop")
[[ -z "$exec_cmd" ]] && exit 1

# 程序名（为了匹配 event-stream）
prog_name=$(awk '{print $1}' <<< "$exec_cmd" | xargs basename)

niri msg action set-column-display tabbed
# 启动 niri 监听
wait_for_window "$prog_name"

# 启动真实程序
exec $exec_cmd
