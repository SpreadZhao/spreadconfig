alias grep="grep --color=auto"
export LESS='-R --use-color -Dd+r$Du+b$'
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"
# alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
