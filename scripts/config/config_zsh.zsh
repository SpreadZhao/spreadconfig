#!/usr/bin/zsh

config_basic() {
    HISTFILE=~/.histfile
    HISTSIZE=5000
    SAVEHIST=5000
    # export KEYTIMEOUT=1
    # enable vim mode in zsh
    bindkey -v
}

# cursor
config_cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
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
    # using ctrl-e to edit your command in $VISUAL
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd ^E edit-command-line

    # surrounding
    autoload -Uz surround
    zle -N delete-surround surround
    zle -N add-surround surround
    zle -N change-surround surround
    bindkey -M vicmd cs change-surround
    bindkey -M vicmd ds delete-surround
    bindkey -M vicmd ys add-surround
    bindkey -M visual S add-surround

    # text objects
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

config_zsh_completion() {
    # https://github.com/Phantas0s/.dotfiles/blob/master/zsh/completion.zsh
    # Load more completions
    fpath=(/usr/share/zsh/site-functions $fpath)

    # Should be called before compinit
    zmodload zsh/complist

    # Use hjlk in menu selection (during completion)
    # Doesn't work well with interactive mode
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -M menuselect 'l' vi-forward-char

    bindkey -M menuselect '^xg' clear-screen
    bindkey -M menuselect '^xi' vi-insert                      # Insert
    bindkey -M menuselect '^xh' accept-and-hold                # Hold
    bindkey -M menuselect '^xn' accept-and-infer-next-history  # Next
    bindkey -M menuselect '^xu' undo                           # Undo

    autoload -U compinit; compinit
    _comp_options+=(globdots) # With hidden files

    # Only work with the Zsh function vman
    # See $DOTFILES/zsh/scripts.zsh
    compdef vman="man"

    # +---------+
    # | Options |
    # +---------+

    # setopt GLOB_COMPLETE      # Show autocompletion menu with globs
    setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
    setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
    setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

    # +---------+
    # | zstyles |
    # +---------+

    # Ztyle pattern
    # :completion:<function>:<completer>:<command>:<argument>:<tag>

    # Define completers
    zstyle ':completion:*' completer _extensions _complete _approximate

    # Use cache for commands using cache
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
    # Complete the alias when _expand_alias is used as a function
    zstyle ':completion:*' complete true

    zle -C alias-expension complete-word _generic
    bindkey '^Xa' alias-expension
    zstyle ':completion:alias-expension:*' completer _expand_alias

    # Use cache for commands which use it

    # Allow you to select in a menu
    zstyle ':completion:*' menu select

    # Autocomplete options for cd instead of directory stack
    zstyle ':completion:*' complete-options true

    zstyle ':completion:*' file-sort modification


    zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
    zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
    zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
    zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
    # zstyle ':completion:*:default' list-prompt '%S%M matches%s'
    # Colors for files and directory
    zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

    # Only display some tags for the command cd
    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
    # zstyle ':completion:*:complete:git:argument-1:' tag-order !aliases

    # Required for completion to be in good groups (named after the tags)
    zstyle ':completion:*' group-name ''

    zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

    # See ZSHCOMPWID "completion matching control"
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

    zstyle ':completion:*' keep-prefix true

    zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
}

config_fzf() {
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
}

config_fzf_tab() {
    fpath=(/usr/share/zsh/site-functions $fpath)
    zmodload zsh/complist
    autoload -U compinit; compinit
    # https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file#configure
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
    zstyle ':completion:*:descriptions' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no
    zstyle ':completion:*' completer _extensions _complete _approximate
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    # custom fzf flags
    # NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
    # zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
    # To make fzf-tab follow FZF_DEFAULT_OPTS.
    # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    # switch group using `<` and `>`
    zstyle ':fzf-tab:*' switch-group '<' '>'
    source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh
}

config_plugins() {
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
}

config_foot() {
    # https://codeberg.org/dnkl/foot/wiki#spawning-new-terminal-instances-in-the-current-working-directory
    autoload -Uz add-zsh-hook
    function osc7-pwd() {
        emulate -L zsh # also sets localoptions for us
        setopt extendedglob
        local LC_ALL=C
        printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
    }

    function chpwd-osc7-pwd() {
        (( ZSH_SUBSHELL )) || osc7-pwd
    }
    add-zsh-hook -Uz chpwd chpwd-osc7-pwd

    # show curr program on title
    # https://codeberg.org/dnkl/foot/issues/242
    function preexec {
        print -Pn "\e]0;${(q)1}(foot)\e\\"
    }

    # pipe last command output
    # https://codeberg.org/dnkl/foot/wiki#zsh-2
    #
    # _precmd_osc133() {
    #     if ! builtin zle; then
    #         print -n "\e]133;D\e\\"
    #     fi
    # }
    #
    # _preexec_osc133() {
    #     print -n "\e]133;C\e\\"
    # }
    #
    # add-zsh-hook precmd  _precmd_osc133
    # add-zsh-hook preexec _preexec_osc133
}

config_other() {
    eval "$(zoxide init zsh)"
    eval "$(starship init zsh)"
    eval "$(fnm env --use-on-cd --shell zsh)"
    # source <(jj util completion zsh)
}

config_basic
config_cursor_mode
config_prompt
# config_zsh_completion
config_fzf
config_fzf_tab          # this should be after fzf config
config_plugins
config_foot
config_other

unset -f config_basic
unset -f config_cursor_mode
unset -f config_prompt
unset -f config_zsh_completion
unset -f config_fzf
unset -f config_fzf_tab
unset -f config_plugins
unset -f config_foot
unset -f config_other
