#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

DELIM=$'\034'

########################################
# 1️⃣ 获取 XDG applications 目录
########################################

get_desktop_dirs() {
    IFS=':' read -ra base <<<"${XDG_DATA_DIRS:-/run/current-system/sw/share}"

    for d in "${base[@]}"; do
        [[ -d "$d/applications" ]] && echo "$d/applications"
    done

    [[ -d "$HOME/.local/share/applications" ]] &&
        echo "$HOME/.local/share/applications"
}

########################################
# 2️⃣ 解析 desktop 文件
########################################

parse_desktop() {
    local file="$1"

    awk '
        /^\[Desktop Entry\]/ { inblock=1; next }
        /^\[/ && !/^\[Desktop Entry\]/ { inblock=0 }

        inblock && /^Type=Application/ { ok=1 }

        inblock && /^Name=/ {
            sub(/^Name=/,"")
            name=$0
        }

        inblock && /^Exec=/ {
            sub(/^Exec=/,"")
            exec=$0
        }

        inblock && /^Comment=/ {
            sub(/^Comment=/,"")
            comment=$0
        }

        inblock && /^Terminal=/ {
            sub(/^Terminal=/,"")
            terminal=$0
        }

        END {
            if(ok && name && exec) {
                if(!terminal) terminal="false"
                printf "%s\034%s\034%s\034%s\034%s\n", \
                    name, exec, comment, FILENAME, terminal
            }
        }
    ' "$file"
}

########################################
# 3️⃣ 构建列表
########################################

build_list() {
    while read -r dir; do
        for f in "$dir"/*.desktop; do
            parse_desktop "$f"
        done
    done < <(get_desktop_dirs)
}

########################################
# 4️⃣ 执行
########################################

clean_exec() {
    local cmd="$1"

    cmd="${cmd//%u/}"
    cmd="${cmd//%U/}"
    cmd="${cmd//%f/}"
    cmd="${cmd//%F/}"
    cmd="${cmd//%i/}"
    cmd="${cmd//%c/}"
    cmd="${cmd//%k/}"
    cmd="${cmd//%%/%}"

    echo "$cmd"
}

run() {
    IFS="$DELIM" read -r name exec comment file terminal <<<"$1"

    exec=$(clean_exec "$exec")

    if [[ "$terminal" == "true" ]]; then
        niri msg action spawn -- \
            footclient -a "$name" -T "$name" -- sh -c "$exec"
    else
        niri msg action spawn -- \
            sh -c "$exec"
    fi
}

########################################
# MAIN
########################################

TMPFILE=$(mktemp)

footclient \
    -a "lick-foot" \
    -T "Launcher" \
    -- sh -c "
        DELIM=$'\034'
        $(declare -f build_list get_desktop_dirs parse_desktop)
        build_list | sort -u | \
        fzf -d \"\$DELIM\" \
            --with-nth=1 \
            --preview 'cat {4}' \
            > \"$TMPFILE\"
    "

CHOICE=$(cat "$TMPFILE")
rm -f "$TMPFILE"

[[ -n "$CHOICE" ]] && run "$CHOICE"
