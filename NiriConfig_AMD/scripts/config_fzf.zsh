#!/usr/bin/zsh

source <(fzf --zsh)

# path
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} | head -200"'
# export FZF_TMUX=1

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Options for path completion (e.g. vim **<TAB>)
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

# Options for directory completion (e.g. cd **<TAB>)
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

# custom function, see /usr/share/fzf/completion.zsh for details
# https://github.com/junegunn/fzf?tab=readme-ov-file#customizing-fzf-options-for-completion
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
    cd)
        fzf --preview 'eza --tree --color=always {} | head -200' "$@"
        ;;
    export | unset)
        fzf --preview 'eval "echo \$ {}"' "$@"
        ;;
    ssh)
        fzf --preview 'dig {}' "$@"
        ;;
    *)
        fzf --preview '
                if [ -d {} ]; then
                    eza --tree --color=always {} | head -200
                else
                    bat -n --color=always {} 2>/dev/null || echo "Cannot preview"
                fi
            ' "$@"
        ;;
    esac
}
