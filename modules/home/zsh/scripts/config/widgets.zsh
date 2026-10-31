lfcd() {
    # Bypass the lf alias when asking the file manager for its last directory.
    cd "$(command lf -print-last-dir "$@")"
}

function vi-yank-wlclip {
    zle vi-yank
    print -rn -- "$CUTBUFFER" | wl-copy --type 'text/plain;charset=utf-8'
}

zle -N vi-yank-wlclip
bindkey -M vicmd 'y' vi-yank-wlclip
