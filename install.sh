#!/usr/bin/bash

CONFIG_ROOT="$HOME/workspaces/spreadconfig"
CONFIG_DIR="$CONFIG_ROOT/UltimateConfig"

apply_from_config_dir() {
    local src_dir="$CONFIG_DIR"
    local dest="$1"

    shift
    mkdir -p "$dest"

    for src in "$@"; do
        if [ -d "$src_dir/$src" ]; then
            cp -r "$src_dir/$src" "$dest/"
        elif [ -f "$src_dir/$src" ]; then
            cp "$src_dir/$src" "$dest/"
        else
            echo "警告: 未找到备份文件/目录: $src_dir/$src" >&2
        fi
    done
}

# 1️⃣ scripts
apply_from_config_dir "$HOME" "scripts"

# 2️⃣ pacman.conf
sudo cp "$CONFIG_DIR/pacman.conf" /etc/

# 3️⃣ IdeaVim
cp "$CONFIG_ROOT/Jetbrains/.ideavimrc" "$HOME/"

# 4️⃣ zshrc
cp "$CONFIG_DIR/.zshrc" "$HOME/"

# 5️⃣ environment
sudo cp "$CONFIG_DIR/environment" /etc/

# 6️⃣ dotfiles（只恢复选定列表）
config_subdirs=(
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
    vivaldi_custom
    wofi
    waybar
)

for subdir in "${config_subdirs[@]}"; do
    src="$CONFIG_DIR/$subdir"
    dest="$HOME/.config"
    if [ -e "$src" ]; then
        mkdir -p "$dest"
        cp -r "$src" "$dest/"
    else
        echo "警告: 未找到 $src" >&2
    fi
done

# 7️⃣ desktop entries
desktop_src="$CONFIG_DIR/desktop_entries"
desktop_dest="$HOME/.local/share/applications"

mkdir -p "$desktop_dest"

if [ -d "$desktop_src" ]; then
    for file in "$desktop_src"/*.desktop; do
        [ -f "$file" ] && cp "$file" "$desktop_dest/"
    done
else
    echo "警告：未找到目录 $desktop_src，跳过 desktop entries 应用"
fi

echo "✅ 配置应用完成！"
