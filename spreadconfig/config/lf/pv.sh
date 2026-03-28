#!/usr/bin/env sh

show_image() {
    img="$1"
    width="$2"
    height="$3"
    x="$4"
    y="$5"

    kitten icat \
        --stdin no \
        --transfer-mode memory \
        --place "${width}x${height}@${x}x${y}" \
        "$img" </dev/null >/dev/tty
    exit 1
}

preview_video() {
    file="$1"
    width="$2"
    height="$3"
    x="$4"
    y="$5"

    tmp_img="$(mktemp --suffix=.png)"

    if ffmpegthumbnailer \
        -i "$file" \
        -o "$tmp_img" \
        -s 0 2>/dev/null; then
        show_image "$tmp_img" "$width" "$height" "$x" "$y"
    fi

    rm -f "$tmp_img"
}

preview_audio() {
    file="$1"
    width="$2"
    height="$3"
    x="$4"
    y="$5"

    tmp_img="$(mktemp --suffix=.png)"

    if ffmpegthumbnailer \
        -i "$file" \
        -o "$tmp_img" \
        -s 0 2>/dev/null; then
        show_image "$tmp_img" "$width" "$height" "$x" "$y"
    fi

    rm -f "$tmp_img"
}

preview_bat() {
    file="$1"
    width="$2"

    bat --force-colorization \
        --paging=never \
        --style=changes,numbers \
        --terminal-width $(($width - 3)) \
        "$file"
}

preview_default() {
    file="$1"
    width="$2"
    height="$3"
    x="$4"
    y="$5"

    if file -b --extension "$file" | tr '/' '\n' | grep -qx ts; then
        preview_video "$file" "$width" "$height" "$x" "$y"
        exit 0
    fi

    preview_bat "$file" "$width"
}

file="$1"
width="$2"
height="$3"
x="$4"
y="$5"

mime_type="$(xdg-mime query filetype "$file")"

case "$mime_type" in
*application/pdf*)
    tmp_img="$(mktemp --suffix=.png)"
    if pdftoppm -singlefile -png -r 100 "$file" >"$tmp_img" 2>/dev/null; then
        show_image "$tmp_img" "$width" "$height" "$x" "$y"
    fi
    rm -f "$tmp_img"
    ;;

*application/x-7z-compressed*)
    7z l "$file"
    ;;

*application/x-tar* | *application/x-*-compressed-tar*)
    tar -tvf "$file"
    ;;

*application/vnd.rar*)
    unrar l "$file"
    ;;

*application/zip*)
    unzip -l "$file"
    ;;

*image/*)
    show_image "$file" "$width" "$height" "$x" "$y"
    ;;

*video/*)
    preview_video "$file" "$width" "$height" "$x" "$y"
    ;;

*audio/*)
    preview_audio "$file" "$width" "$height" "$x" "$y"
    ;;

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
    preview_default "$file" "$width" "$height" "$x" "$y"
    ;;

text/*)
    preview_default "$file" "$width" "$height" "$x" "$y"
    ;;

*)
    preview_default "$file" "$width" "$height" "$x" "$y" || true
    ;;
esac
