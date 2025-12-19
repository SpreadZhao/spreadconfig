#!/usr/bin/bash

CONFIG_ROOT="$HOME/workspaces/spreadconfig"
CONFIG_DIR="$CONFIG_ROOT"

copy_to_config_dir() {
    local dest_dir="$CONFIG_DIR"
    local opt

    # 关键：使用函数参数副本
    local args=("$@")
    local i=0

    while [ $i -lt ${#args[@]} ]; do
        case "${args[$i]}" in
        -d)
            dest_dir="${args[$((i + 1))]}"
            i=$((i + 2))
            ;;
        --)
            i=$((i + 1))
            break
            ;;
        -*)
            echo "用法: copy_to_config_dir [-d dest_dir] src..." >&2
            return 1
            ;;
        *)
            break
            ;;
        esac
    done

    # 剩余参数
    local sources=("${args[@]:$i}")

    if [ -z "$dest_dir" ]; then
        echo "错误: 目标目录为空" >&2
        return 1
    fi

    if [ "${#sources[@]}" -eq 0 ]; then
        echo "错误: 未指定要拷贝的文件或目录" >&2
        return 1
    fi

    mkdir -p "$dest_dir"

    for src in "${sources[@]}"; do
        if [ -d "$src" ]; then
            cp -r "$src" "$dest_dir/"
        elif [ -f "$src" ]; then
            cp "$src" "$dest_dir/"
        else
            echo "警告: 源路径不存在或不是文件/目录: $src" >&2
        fi
    done
}

clear_nvim_gitignore() {
    nvim_dest="$CONFIG_DIR/config/nvim"
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

find "$CONFIG_DIR" -mindepth 1 \
    ! -path "$CONFIG_DIR/.git*" \
    ! -path "$CONFIG_DIR/packages*" \
    -exec rm -rf {} +

# scripts
copy_to_config_dir "$HOME/scripts"

# etc
copy_to_config_dir -d "$CONFIG_DIR/etc" "/etc/pacman.conf"
copy_to_config_dir -d "$CONFIG_DIR/etc" "/etc/environment"
copy_to_config_dir -d "$CONFIG_DIR/etc" "/etc/greetd"

# IdeaVim
copy_to_config_dir -d "$CONFIG_DIR/Jetbrains" "$HOME/.ideavimrc"

# zshrc
copy_to_config_dir "$HOME/.zshrc"

paru -Qqetn >"$CONFIG_DIR/package-list-temp.txt"
paru -Qqem >"$CONFIG_DIR/package-list-aur-temp.txt"
paru -Qq >"$CONFIG_DIR/package-list-all.txt"

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
    satty
    # swappy
    starship.toml
    systemd
    vivaldi_custom
    wofi
    waybar
)

for subdir in "${config_subdirs[@]}"; do
    copy_to_config_dir -d "$CONFIG_DIR/config" "$HOME/.config/$subdir"
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
    ghidra
    jadx
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
