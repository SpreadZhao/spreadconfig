#!/bin/bash

# 用法提示
usage() {
    echo "用法: $0 [pkglist路径]"
    echo "如果未提供路径，默认使用 ./pkglist.txt"
    exit 1
}

# 获取参数
PKGLIST="${1:-./pkglist.txt}"

# 检查文件是否存在
if [[ ! -f "$PKGLIST" ]]; then
    echo "错误: 找不到文件 '$PKGLIST'"
    usage
fi

# 主操作：提取存在于仓库中的包并安装未安装的
echo "正在从 '$PKGLIST' 安装存在于官方仓库且未安装的软件包..."

pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort "$PKGLIST"))
