#!/usr/bin/bash

CONFIG_DIR="$HOME/workspaces/spreadconfig/NiriConfig_AMD"

copy_to_config_dir() {
    local dest_dir="$CONFIG_DIR"
    mkdir -p "$dest_dir"

    for src in "$@"; do
        if [ -d "$src" ]; then
            # 复制整个目录
            cp -r "$src" "$dest_dir/"
        elif [ -f "$src" ]; then
            # 复制单个文件
            cp "$src" "$dest_dir/"
        else
            echo "警告: 源路径不存在或不是文件/目录: $src" >&2
        fi
    done
}

clear_nvim_gitignore() {
    nvim_dest="$CONFIG_DIR/nvim"
    gitignore_file="$nvim_dest/.gitignore"

    if [ -f "$gitignore_file" ]; then
        while IFS= read -r line; do
            pattern="$(echo "$line" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            if [[ -z "$pattern" || "$pattern" == \#* ]]; then
                continue
            fi

            target_path="$nvim_dest/$pattern"
            files=($target_path)

            for file in "${files[@]}"; do
                if [ -e "$file" ]; then
                    rm "$file"
                fi
            done
        done <"$gitignore_file"
    else
        echo "警告：未找到 $gitignore_file，跳过清理"
    fi
}


# scripts
copy_to_config_dir "$HOME/scripts"

# pacman & aur
copy_to_config_dir "/etc/pacman.conf"
paru -Qqetn > "$CONFIG_DIR/package-list-temp.txt"
paru -Qqem > "$CONFIG_DIR/package-list-aur-temp.txt"
paru -Qq > "$CONFIG_DIR/package-list-all.txt"

# dotfiles
config_subdirs=(
    btop
    # dunst
    fontconfig
    foot
    # ghostty
    gtk-3.0
    gtk-4.0
    # i3blocks
    lazygit
    mako
    niri
    nwg-look
    nvim
    paru
    swappy
    starship.toml
    # sway
    wofi
    waybar
)

for subdir in "${config_subdirs[@]}"; do
    copy_to_config_dir "$HOME/.config/$subdir"
done

clear_nvim_gitignore
