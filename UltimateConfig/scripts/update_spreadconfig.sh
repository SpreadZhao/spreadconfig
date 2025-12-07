#!/usr/bin/bash

CONFIG_ROOT="$HOME/workspaces/spreadconfig"
CONFIG_DIR="$CONFIG_ROOT/UltimateConfig"

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

# IdeaVim
cp "$HOME/.ideavimrc" "$CONFIG_ROOT/Jetbrains/"

# zshrc
copy_to_config_dir "$HOME/.zshrc"

# system env
copy_to_config_dir /etc/environment

# dotfiles
config_subdirs=(
    # btop
    cliphist
    fontconfig
    foot
    gtk-3.0
    gtk-4.0
    lazygit
    mako
    niri
    nwg-look
    nvim
    paru
    swappy
    starship.toml
    systemd
    vivaldi_custom
    wofi
    waybar
)

for subdir in "${config_subdirs[@]}"; do
    copy_to_config_dir "$HOME/.config/$subdir"
done

clear_nvim_gitignore

desktop_src="$HOME/.local/share/applications"
desktop_dest="$CONFIG_DIR/desktop_entries"

# ✅ 在这里定义白名单，如果为空则拷贝全部
# 例子：("a" "b") 表示只复制 a.desktop 和 b.desktop
desktop_whitelist=(
    qq
    wechat
    change_audio
    reboot
    shutdown
    obsidian
    foot_new_tab
)

mkdir -p "$desktop_dest"

if [ -d "$desktop_src" ]; then
    if [ ${#desktop_whitelist[@]} -eq 0 ]; then
        # 白名单为空 → 拷贝全部
        cp -r "$desktop_src"/* "$desktop_dest/"
    else
        # 按白名单拷贝
        for name in "${desktop_whitelist[@]}"; do
            src_file="$desktop_src/${name}.desktop"
            if [ -f "$src_file" ]; then
                cp "$src_file" "$desktop_dest/"
            else
                echo "警告: 未找到 $src_file" >&2
            fi
        done
    fi
else
    echo "警告：未找到目录 $desktop_src，跳过 desktop entries 复制"
fi
