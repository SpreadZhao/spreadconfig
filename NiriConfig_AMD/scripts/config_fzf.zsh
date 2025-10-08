#!/usr/bin/zsh

source <(fzf --zsh)

# path
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} | head -200"'
export FZF_COMPLETION_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
# export FZF_TMUX=1

# custom function, see /usr/share/fzf/completion.zsh for details
_fzf_comprun() {
    local command=$1
    shift
    case "$command" in
        cd)             fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset)   fzf --preview 'eval "echo \$ {}"' "$@" ;;
        ssh)            fzf --preview 'dig {}' "$@" ;;
        *)              fzf --preview "--preview 'bat -n --color=always --style=numbers --line-range=:500 {}'" "$@" ;;
    esac
}
