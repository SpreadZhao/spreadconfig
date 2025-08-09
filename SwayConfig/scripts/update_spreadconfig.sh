#!/usr/bin/bash

CONFIG_DIR="$HOME/workspaces/spreadconfig/SwayConfig"

copy_to_config_dir() {
    local dest_dir="$CONFIG_DIR"
    mkdir -p "$dest_dir"

    for src_dir in "$@"; do
        if [ -d "$src_dir" ]; then
            cp -r "$src_dir" "$dest_dir/"
        else
            echo "警告: 源目录不存在或不是目录: $src_dir" >&2
        fi
    done
}

clear_nvim_gitignore() {
    nvim_dest="$CONFIG_DIR/nvim"
    gitignore_file="$nvim_dest/.gitignore"

    if [ -f "$gitignore_file" ]; then
        # 读每一行，忽略空行和注释行
        while IFS= read -r line; do
            # 去掉前后空白
            pattern="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

            # 跳过空行和注释行
            if [[ -z "$pattern" || "$pattern" == \#* ]]; then
                continue
            fi

            # 生成要删除的文件路径（相对路径转成绝对路径）
            target_path="$nvim_dest/$pattern"

            # 使用 glob 扩展匹配多文件
            # shellcheck disable=SC2086
            files=($target_path)

            for file in "${files[@]}"; do
                if [ -e "$file" ]; then
                    rm -i "$file"
                fi
            done
        done <"$gitignore_file"
    else
        echo "警告：未找到 $gitignore_file，跳过清理"
    fi
}

# pacman & aur
paru -Qqetn >"$CONFIG_DIR/package-list.txt"
paru -Qqem >"$CONFIG_DIR/package-list-aur.txt"

# scripts
copy_to_config_dir "$HOME/scripts"

# dotfiles
config_subdirs=(
    dunst
    foot
    i3blocks
    lazygit
    nwg-look
    nvim
    paru
    swappy
    sway
    wofi
)

for subdir in "${config_subdirs[@]}"; do
    copy_to_config_dir "$HOME/.config/$subdir"
done

clear_nvim_gitignore
