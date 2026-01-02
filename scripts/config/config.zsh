ZSH_CONFIG_DIR="${0:A:h}"

source "$ZSH_CONFIG_DIR/env.sh"
source "$ZSH_CONFIG_DIR/alias.sh"
source "$ZSH_CONFIG_DIR/color_output.sh"
source "$ZSH_CONFIG_DIR/config_zsh.zsh"
# source "$ZSH_CONFIG_DIR/config_jj.zsh"

unset -v ZSH_CONFIG_DIR
