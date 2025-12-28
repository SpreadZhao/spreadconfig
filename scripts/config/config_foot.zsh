# https://codeberg.org/dnkl/foot/wiki#spawning-new-terminal-instances-in-the-current-working-directory
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
# autoload -Uz add-zsh-hook
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
