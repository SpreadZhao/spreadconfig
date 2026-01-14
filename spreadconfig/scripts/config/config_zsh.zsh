# ==============================================================================
# Core shell configuration (history, vim mode)
# ==============================================================================
config_basic() {
    # Set the path for zsh history file (stores command history persistently)
    HISTFILE=~/.zsh_history
    # Maximum number of history entries kept in memory (session)
    HISTSIZE=5000
    # Maximum number of history entries saved to HISTFILE (persistent)
    SAVEHIST=5000
    # export KEYTIMEOUT=1  # Uncomment to set key delay (10ms) for vim mode

    # Enable vi/vim key binding mode in zsh (replace default emacs mode)
    bindkey -v
}

# ==============================================================================
# Cursor shape configuration for vim mode (block/beam)
# ==============================================================================
config_cursor_mode() {
    # Cursor shape escape sequences (from ttssh2 documentation)
    # Block cursor (vicmd/normal mode)
    cursor_block='\e[2 q'
    # Beam/vertical bar cursor (viins/insert mode)
    cursor_beam='\e[6 q'

    # ZLE hook function to switch cursor shape based on vim mode
    function zle-keymap-select {
        # Switch to block cursor if in vicmd (normal) mode or explicit block request
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        # Switch to beam cursor if in insert mode (main/viins) or explicit beam request
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    # ZLE hook function to initialize cursor shape on new command line
    zle-line-init() {
        # Start with beam cursor (insert mode) when new prompt loads
        echo -ne $cursor_beam
    }

    # Register the custom ZLE hook functions
    zle -N zle-keymap-select
    zle -N zle-line-init
}

# ==============================================================================
# Prompt and vim-style editing enhancements
# ==============================================================================
config_prompt() {
    # Load and bind "edit-command-line" widget (edit current command in $VISUAL editor)
    autoload -Uz edit-command-line
    zle -N edit-command-line
    # Bind Ctrl+E (in vicmd mode) to open current command in editor (e.g. vim)
    bindkey -M vicmd ^E edit-command-line

    # Load zsh-surround module (vim-surround like functionality for zsh)
    autoload -Uz surround
    # Register surround widgets for delete/add/change operations
    zle -N delete-surround surround
    zle -N add-surround surround
    zle -N change-surround surround
    # Bind vim-style keys for surround operations (vicmd mode)
    bindkey -M vicmd cs change-surround  # cs<char1><char2>: change surround char1 to char2
    bindkey -M vicmd ds delete-surround  # ds<char>: delete surround char
    bindkey -M vicmd ys add-surround     # ys<motion><char>: add surround char
    bindkey -M visual S add-surround     # S<char>: add surround in visual mode

    # Load text object modules (select quoted/bracketed text like vim)
    autoload -Uz select-bracketed select-quoted
    # Register text object widgets
    zle -N select-quoted
    zle -N select-bracketed
    # Bind text object keys for viopp (operator pending) and visual modes
    for km in viopp visual; do
      # Fix conflict with "-" key (use vi-up-line-or-history instead of default)
      bindkey -M $km -- '-' vi-up-line-or-history
      # Bind a/i + quote chars (', ", `, |, ,, ., /, :, ;, =, +, @) to select quoted text
      for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
        bindkey -M $km $c select-quoted
      done
      # Bind a/i + bracket chars ((), [], {}, <>, b, B) to select bracketed text
      for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $km $c select-bracketed
      done
    done
}

# ==============================================================================
# Deprecated zsh completion configuration (replaced by config_fzf_tab)
# ==============================================================================
config_zsh_completion() {
    # Extend fpath to include system-wide completion files
    fpath=(/usr/share/zsh/site-functions $fpath)

    # Load zsh completion module (must be called before compinit)
    zmodload zsh/complist

    # Bind vim-style hjlk keys for menu selection (completion menu navigation)
    # Note: May conflict with interactive mode
    bindkey -M menuselect 'h' vi-backward-char    # Left
    bindkey -M menuselect 'k' vi-up-line-or-history  # Up
    bindkey -M menuselect 'j' vi-down-line-or-history  # Down
    bindkey -M menuselect 'l' vi-forward-char     # Right

    # Additional menuselect key bindings (Ctrl+X + [g/i/h/n/u])
    bindkey -M menuselect '^xg' clear-screen                # Ctrl+X+G: Clear screen
    bindkey -M menuselect '^xi' vi-insert                   # Ctrl+X+I: Switch to insert mode
    bindkey -M menuselect '^xh' accept-and-hold             # Ctrl+X+H: Accept and hold current selection
    bindkey -M menuselect '^xn' accept-and-infer-next-history  # Ctrl+X+N: Accept and infer next
    bindkey -M menuselect '^xu' undo                        # Ctrl+X+U: Undo selection

    # Initialize zsh completion system
    autoload -U compinit; compinit
    # Include hidden files (dotfiles) in completion
    _comp_options+=(globdots)

    # Map completion for custom vman function to man command (requires vman in scripts.zsh)
    compdef vman="man"

    # +---------+
    # | Options |
    # +---------+
    # setopt GLOB_COMPLETE      # Show completion menu for glob patterns
    setopt MENU_COMPLETE        # Auto-highlight first completion entry
    setopt AUTO_LIST            # Auto-list choices for ambiguous completions
    setopt COMPLETE_IN_WORD     # Complete from both ends of a word

    # +---------+
    # | zstyles | Completion style configuration (pattern: :completion:<func>:<completer>:<cmd>:<arg>:<tag>)
    # +---------+

    # Define completion handlers (extensions → complete → approximate matching)
    zstyle ':completion:*' completer _extensions _complete _approximate

    # Enable completion cache (speed up repeated completions)
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
    # Complete aliases when _expand_alias is used
    zstyle ':completion:*' complete true

    # Bind Ctrl+X+A to expand aliases (custom completion widget)
    zle -C alias-expension complete-word _generic
    bindkey '^Xa' alias-expension
    zstyle ':completion:alias-expension:*' completer _expand_alias

    # Use fzf-style menu for completion selection
    zstyle ':completion:*' menu select

    # Complete cd options instead of directory stack
    zstyle ':completion:*' complete-options true

    # Sort files by modification time (newest first)
    zstyle ':completion:*' file-sort modification

    # Completion message formatting (colors for errors/descriptions/messages/warnings)
    zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
    zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
    zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
    zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'

    # Use LS_COLORS for file/directory colors in completion list
    zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}

    # Prioritize local directories for cd completion
    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

    # Group completions by category (named after tags)
    zstyle ':completion:*' group-name ''

    # Order of completion groups for commands (aliases → builtins → functions → commands)
    zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

    # Completion matching rules (case-insensitive, partial matching with separators)
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

    # Keep prefix when completing (preserve typed text)
    zstyle ':completion:*' keep-prefix true

    # SSH host completion (read from /etc/ssh/ and ~/.ssh/known_hosts)
    zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
}

# ==============================================================================
# FZF (fuzzy finder) configuration
# ==============================================================================
config_fzf() {
    # Load official FZF zsh integration
    source <(fzf --zsh)

    # FZF Ctrl+T options (file selection): preview with bat (syntax highlighting)
    export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
    # FZF Alt+C options (directory selection): preview with eza (tree view)
    export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} | head -200"'
    # export FZF_TMUX=1  # Uncomment to use FZF in tmux pane

    # Global FZF completion options (border, inline info)
    export FZF_COMPLETION_OPTS='--border --info=inline'

    # FZF path completion options (e.g. vim **<TAB>): include files/dirs/symlinks/hidden
    export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

    # FZF directory completion options (e.g. cd **<TAB>): include dirs/symlinks
    export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

    # Custom FZF runner for different commands (override default behavior)
    # See /usr/share/fzf/completion.zsh for default implementation
    _fzf_comprun() {
        local command=$1
        shift
        case "$command" in
        # cd: preview directory tree with eza
        cd)
            fzf --preview 'eza --tree --color=always {} | head -200' "$@"
            ;;
        # export/unset: preview environment variable values
        export | unset)
            fzf --preview 'eval "echo \$ {}"' "$@"
            ;;
        # ssh: preview host info with dig
        ssh)
            fzf --preview 'dig {}' "$@"
            ;;
        # Default: preview dirs with eza, files with bat (fallback to "Cannot preview")
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

# ==============================================================================
# FZF-Tab configuration (fuzzy completion for zsh tab)
# Note: Must be loaded after FZF config
# ==============================================================================
config_fzf_tab() {
    # Extend fpath for system-wide completion files
    # fpath=(
    #     "$(nix path-info nixpkgs#zsh-completions)/share/zsh/site-functions"
    #     $fpath
    # )
    # Load zsh completion module
    zmodload zsh/complist
    # Initialize completion system
    # autoload -U compinit; compinit

    # ===================== Basic completion config (from config_zsh_completion, non-conflicting) =====================
    # Enable completion cache (speed up repeated completions)
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

    # Complete aliases when using _expand_alias
    zstyle ':completion:*' complete true
    zle -C alias-expension complete-word _generic
    bindkey '^Xa' alias-expension
    zstyle ':completion:alias-expension:*' completer _expand_alias

    # Complete cd options instead of directory stack
    zstyle ':completion:*' complete-options true

    # Sort files by modification time
    zstyle ':completion:*' file-sort modification

    # Prioritize local directories for cd completion
    zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

    # Group completions by category
    zstyle ':completion:*' group-name ''

    # Order of command completion groups
    zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

    # Completion matching rules (case-insensitive, partial matching)
    zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

    # Keep prefix when completing
    zstyle ':completion:*' keep-prefix true

    # SSH host completion (read from known_hosts)
    zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

    # ===================== FZF-Tab specific config =====================
    # Disable sorting for git checkout completion (preserve branch order)
    zstyle ':completion:*:git-checkout:*' sort false

    # Simplify completion description format (override default)
    zstyle ':completion:*:descriptions' format '[%d]'

    # Use LS_COLORS for list colors
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    # Disable default completion menu (use FZF instead)
    zstyle ':completion:*' menu no

    # Use default completers (extensions → complete → approximate)
    zstyle ':completion:*' completer _extensions _complete _approximate

    # FZF-Tab core config
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'  # Preview cd targets with eza
    zstyle ':fzf-tab:*' use-fzf-default-opts yes                                    # Use FZF_DEFAULT_OPTS
    zstyle ':fzf-tab:*' switch-group '<' '>'                                        # Switch completion groups with < >

    # Load FZF-Tab plugin
    source $(nix path-info nixpkgs#zsh-fzf-tab)/share/fzf-tab/fzf-tab.zsh
}

# ==============================================================================
# Zsh plugin configuration (syntax highlighting, autosuggestions)
# ==============================================================================
config_plugins() {
    # Load zsh-syntax-highlighting (colorize commands in real-time)
    source "$(nix path-info nixpkgs#zsh-syntax-highlighting)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    # Load zsh-autosuggestions (suggest commands from history)
    source "$(nix path-info nixpkgs#zsh-autosuggestions)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
}

# ==============================================================================
# Foot terminal emulator integration
# ==============================================================================
config_foot() {
    # OSC 7 escape sequence: notify Foot of current working directory (open new windows in same dir)
    # See: https://codeberg.org/dnkl/foot/wiki#spawning-new-terminal-instances-in-the-current-working-directory
    autoload -Uz add-zsh-hook
    function osc7-pwd() {
        emulate -L zsh  # Use POSIX emulation + local options
        setopt extendedglob
        local LC_ALL=C
        # Encode current directory and send OSC 7 sequence to Foot
        printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
    }

    # Call osc7-pwd on directory change (chpwd hook)
    function chpwd-osc7-pwd() {
        # Skip in subshells to avoid unnecessary sequences
        (( ZSH_SUBSHELL )) || osc7-pwd
    }
    add-zsh-hook -Uz chpwd chpwd-osc7-pwd

    # Set Foot window title to current command (preexec hook: runs before command execution)
    # See: https://codeberg.org/dnkl/foot/issues/242
    function preexec {
        print -Pn "\e]0;${(q)1}(foot)\e\\"
    }

    # OSC 133 sequence support (command start/end markers for Foot)
    # Uncomment to enable:
    # _precmd_osc133() {
    #     if ! builtin zle; then
    #         print -n "\e]133;D\e\\"  # Command end marker
    #     fi
    # }
    #
    # _preexec_osc133() {
    #     print -n "\e]133;C\e\\"      # Command start marker
    # }
    #
    # add-zsh-hook precmd  _precmd_osc133
    # add-zsh-hook preexec _preexec_osc133
}

# ==============================================================================
# Other tool integrations (zoxide, starship, fnm)
# ==============================================================================
config_other() {
    # Initialize zoxide (smart cd alternative) for zsh
    eval "$(zoxide init zsh)"
    # Initialize starship (custom prompt) for zsh
    export STARSHIP_CONFIG=$HOME/.config/starship.toml
    eval "$(starship init zsh)"
    # Initialize fnm (Node.js version manager) with auto-switch on cd
    eval "$(fnm env --use-on-cd --shell zsh)"
    # Initialize jj (Git alternative) completion (uncomment to enable)
    # source <(jj util completion zsh)
}

# ==============================================================================
# Execute all configuration functions
# ==============================================================================
config_basic
config_cursor_mode
config_prompt
config_fzf
config_fzf_tab          # Must be loaded after FZF config
config_plugins
config_foot
config_other

# ==============================================================================
# Cleanup: Unset configuration functions to reduce shell memory footprint
# ==============================================================================
unset -f config_basic
unset -f config_cursor_mode
unset -f config_prompt
unset -f config_zsh_completion
unset -f config_fzf
unset -f config_fzf_tab
unset -f config_plugins
unset -f config_foot
unset -f config_other
