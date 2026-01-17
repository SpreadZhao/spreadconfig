# export EDITOR=nvim
# export VISUAL=nvim

# xdg
# export XDG_CONFIG_HOME=$HOME/.config
# export XDG_CACHE_HOME=$HOME/.cache
# export XDG_DATA_HOME=$HOME/.local/share
# export XDG_STATE_HOME=$HOME/.local/state

# custom
export SCRIPT_HOME=$HOME/scripts

{
  echo "===== sourced at $(date) ====="
  echo "PID=$$"
  echo "BASH_SOURCE:"
  printf '  %s\n' "${BASH_SOURCE[@]}"
  echo "FUNCNAME:"
  printf '  %s\n' "${FUNCNAME[@]}"
  echo "=============================="
} >> ~/temp/source-trace.log

# PATH
append_path() {
    for p in "$@"; do
        p="${p%/}"
        if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
            PATH="$p:$PATH"
        fi
    done
}

PATH_LIST=(
    "$SCRIPT_HOME/util/bin"
    "$SCRIPT_HOME/nix"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/Android/Sdk/platform-tools"
)

append_path "${PATH_LIST[@]}"

unset -f append_path
unset -v PATH_LIST

export PATH
