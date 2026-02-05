#!/usr/bin/env sh

show_by_chafa() {
    img="$1"
    width="$2"
    height="$3"

    chafa -f sixel -s "${width}x${height}" \
        --animate off \
        --polite on \
        -t 1 \
        --bg black \
        "$img"
}

preview_video() {
    file="$1"
    width="$2"
    height="$3"

    tmp_img="$(mktemp --suffix=.png)"

    if ffmpegthumbnailer \
        -i "$file" \
        -o "$tmp_img" \
        -s 0 2>/dev/null; then
        show_by_chafa "$tmp_img" "$width" "$height"
    fi

    rm -f "$tmp_img"
}

preview_audio() {
    file="$1"
    width="$2"
    height="$3"

    tmp_img="$(mktemp --suffix=.png)"

    if ffmpegthumbnailer \
        -i "$file" \
        -o "$tmp_img" \
        -s 0 2>/dev/null; then
        show_by_chafa "$tmp_img" "$width" "$height"
    fi

    rm -f "$tmp_img"
}

preview_bat() {
    file="$1"
    width="$2"

    bat --force-colorization --paging=never --style=changes,numbers \
        --terminal-width $(($width - 3)) "$file" && false
}

preview_default() {
    file="$1"
    width="$2"
    height="$3"

    if file -b --extension "$file" | tr '/' '\n' | grep -qx ts; then
        preview_video "$file" "$width" "$height"
        exit 0
    fi

    preview_bat "$file" "$width"
}

file="$1"
width="$2"
height="$3"

mime_type="$(xdg-mime query filetype "$file")"

case "$mime_type" in
*application/pdf*)
    tmp_img="$(mktemp --suffix=.png)"
    if pdftoppm -singlefile -png -r 100 "$file" >"$tmp_img" 2>/dev/null; then
        show_by_chafa "$tmp_img" "$width" "$height"
    fi
    rm -f "$tmp_img"
    ;;

*application/x-7z-compressed*)
    7z l "$file"
    ;;

*application/x-tar*)
    tar -tvf "$file"
    ;;

*application/x-compressed-tar* | *application/x-*-compressed-tar*)
    tar -tvf "$file"
    ;;

*application/vnd.rar*)
    unrar l "$file"
    ;;

*application/zip*)
    unzip -l "$file"
    ;;

*image/*)
    show_by_chafa "$file" "$width" "$height"
    ;;

*video/*)
    preview_video "$file" "$width" "$height"
    ;;

*audio/*)
    preview_audio "$file" "$width" "$height"
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
    preview_default "$file" "$width" "$height"
    ;;

text/*)
    preview_default "$file" "$width" "$height"
    ;;

*)
    preview_default "$file" "$width" "$height" || true
    ;;
esac
