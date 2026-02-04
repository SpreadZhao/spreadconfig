#!/usr/bin/env sh

preview_text() {
    bat --force-colorization --paging=never --style=changes,numbers \
        --terminal-width $(($2 - 3)) "$1" && false
}

MIME=$(xdg-mime query filetype "$1")

case "$MIME" in
*application/pdf*)
    tmp_img="$(mktemp --suffix=.png)"
    if pdftoppm -singlefile -png -r 100 "$1" >"$tmp_img" 2>/dev/null; then
        chafa -f sixel -s "$2x$3" --animate off --polite on -t 1 --bg black "$tmp_img"
    fi
    rm -f "$tmp_img"
    ;;

*application/x-7z-compressed*)
    7z l "$1"
    ;;

*application/x-tar*)
    tar -tvf "$1"
    ;;

*application/x-compressed-tar* | *application/x-*-compressed-tar*)
    tar -tvf "$1"
    ;;

*application/vnd.rar*)
    unrar l "$1"
    ;;

*application/zip*)
    unzip -l "$1"
    ;;

*image/*)
    chafa -f sixel -s "$2x$3" --animate off --polite on -t 1 --bg black "$1"
    ;;

*video/*)
    tmp_img="$(mktemp --suffix=.png)"

    # 取视频中间一帧（-t 50%），失败就安静退出
    if ffmpegthumbnailer \
        -i "$1" \
        -o "$tmp_img" \
        -s 0 2>/dev/null; then
        chafa -f sixel -s "$2x$3" \
            --animate off \
            --polite on \
            -t 1 \
            --bg black \
            "$tmp_img"
    fi

    rm -f "$tmp_img"
    ;;

# ===== 明确的“文本类 application/*” =====
*application/json* | \
    *application/xml* | \
    *application/xhtml+xml* | \
    *application/javascript* | \
    *application/x-yaml* | \
    *application/yaml* | \
    *application/toml* | \
    *application/x-shellscript* | \
    *application/x-python* | \
    *application/x-ruby* | \
    *application/x-lua* | \
    *application/x-php*)
    preview_text "$1" "$2"
    ;;

# ===== 标准 text/* =====
text/*)
    preview_text "$1" "$2"
    ;;

# ===== 兜底：尝试当文本预览 =====
*)
    preview_text "$1" "$2" || true
    ;;
esac
