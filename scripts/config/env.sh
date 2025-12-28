export EDITOR=nvim
export VISUAL=nvim

# xdg
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# custom
export SCRIPT_HOME=$HOME/scripts

# PATH
append_path() {
    for p in "$@"; do
        p="${p%/}"
        if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
            PATH="$PATH:$p"
        fi
    done
}

PATH_LIST=(
    "$SCRIPT_HOME/util/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
)

append_path "${PATH_LIST[@]}"

unset -f append_path

export PATH
