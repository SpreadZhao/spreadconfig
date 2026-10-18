# Use a block cursor in normal mode and a beam in insert mode.
config_cursor_mode() {
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

config_prompt() {
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd ^E edit-command-line

    autoload -Uz surround
    zle -N delete-surround surround
    zle -N add-surround surround
    zle -N change-surround surround
    bindkey -M vicmd cs change-surround  # cs<char1><char2>: change surround char1 to char2
    bindkey -M vicmd ds delete-surround  # ds<char>: delete surround char
    bindkey -M vicmd ys add-surround     # ys<motion><char>: add surround char
    bindkey -M visual S add-surround     # S<char>: add surround in visual mode

    autoload -Uz select-bracketed select-quoted
    zle -N select-quoted
    zle -N select-bracketed
    for km in viopp visual; do
      bindkey -M $km -- '-' vi-up-line-or-history
      for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
        bindkey -M $km $c select-quoted
      done
      for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $km $c select-bracketed
      done
    done
}

config_fzf() {
    export FZF_COMPLETION_OPTS='--border --info=inline'

    export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

    export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

    export FZF_DEFAULT_OPTS=" \
    --color=bg:#000000,bg+:#3a3a3a \
    --color=fg:#ADAEAC,fg+:#ADAEAC \
    --color=hl:#47A2ED,hl+:#47A2ED \
    --color=prompt:#CC85C6,pointer:#47CCB1 \
    --color=marker:#E6E6AA \
    --color=header:#CC85C6,info:#6A9955 \
    --color=spinner:#47CCB1 \
    --color=selected-bg:#262626 \
    --color=border:#7C7C7C,label:#ADAEAC"

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
            fzf --preview 'dig {}'
            ;;
        *)
            fzf --preview '
                if [ -d {} ]; then
                    eza --tree --color=always {} | head -200
                else
                    "$SCRIPT_HOME/config/fzf_preview.sh" {}
                fi
            ' "$@"
            ;;
        esac
    }
}

# Initialize after config_fzf so fzf-tab inherits FZF_DEFAULT_OPTS.
config_fzf_tab() {
    zmodload zsh/complist

    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

    zstyle ':completion:*' complete true
    zle -C alias-expension complete-word _generic
    bindkey '^Xa' alias-expension
    zstyle ':completion:alias-expension:*' completer _expand_alias

    zstyle ':completion:*' complete-options true

    zstyle ':completion:*' file-sort modification

    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

    zstyle ':completion:*' group-name ''

    zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

    zstyle ':completion:*' keep-prefix true

    zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

    zstyle ':completion:*:git-checkout:*' sort false

    zstyle ':completion:*:descriptions' format '[%d]'

    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    zstyle ':completion:*' menu no

    zstyle ':completion:*' completer _extensions _complete _approximate

    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'  # Preview cd targets with eza
    zstyle ':fzf-tab:*' use-fzf-default-opts yes                                    # Use FZF_DEFAULT_OPTS
    zstyle ':fzf-tab:*' switch-group '<' '>'                                        # Switch completion groups with < >
}

# Send the working directory through OSC 7 and the command as the window title.
config_foot() {
    autoload -Uz add-zsh-hook
    function osc7-pwd() {
        emulate -L zsh  # Keep zsh options local to this function.
        setopt extendedglob
        local LC_ALL=C
        printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
    }

    function chpwd-osc7-pwd() {
        (( ZSH_SUBSHELL )) || osc7-pwd
    }
    add-zsh-hook -Uz chpwd chpwd-osc7-pwd

    function preexec {
        printf '\e]0;%s(foot)\e\\' "${(q)1}"
    }

}

config_other() {
    source <(tdl completion zsh)
}

config_cursor_mode
config_prompt
config_fzf
config_fzf_tab          # Must be loaded after FZF config
config_foot
config_other

unset -f config_cursor_mode
unset -f config_prompt
unset -f config_fzf
unset -f config_fzf_tab
unset -f config_foot
unset -f config_other
