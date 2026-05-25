#!/usr/bin/env bash
# mpvf - fzf + mpv 文件选择器

SEARCH_DIR="${1:-.}"

shift || true   # 如果给了目录参数，把它去掉，后面就是过滤关键字
FILTER="$*"

if [ -n "$FILTER" ]; then
    # 如果用户给了关键字，就直接用 fzf --filter 非交互过滤
    mapfile -t files < <(find "$SEARCH_DIR" -type f \
        | fzf --filter "$FILTER")
else
    # 否则进入交互模式
    mapfile -t files < <(find "$SEARCH_DIR" -type f \
        | fzf --multi --select-1 --exit-0)
fi

# 如果没有选择/匹配，退出
[ ${#files[@]} -eq 0 ] && exit 0

# 交给 mpv 播放
mpv "${files[@]}"
