#!/usr/bin/env bash
set -euo pipefail

MODE="$1"
INPUT="$2"
PASSWORD="$3"

# 临时文件自动删除
tmp_in=$(mktemp)
tmp_out=$(mktemp)
trap 'rm -f "$tmp_in" "$tmp_out"' EXIT

# 写输入字符串到临时文件
printf '%s' "$INPUT" > "$tmp_in"

if [[ "$MODE" == "encrypt" ]]; then
  openssl enc -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" -salt -base64 -in "$tmp_in" -out "$tmp_out"
  cat "$tmp_out"
elif [[ "$MODE" == "decrypt" ]]; then
  openssl enc -aes-256-cbc -pbkdf2 -pass pass:"$PASSWORD" -salt -base64 -d -in "$tmp_in" -out "$tmp_out"
  cat "$tmp_out"
else
  echo "Usage: $0 encrypt|decrypt <string> <password>" >&2
  exit 1
fi
