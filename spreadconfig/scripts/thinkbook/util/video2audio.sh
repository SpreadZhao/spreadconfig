#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_dir> <output_dir>"
  exit 1
fi

INPUT_DIR="$(realpath "$1")"
OUTPUT_DIR="$(realpath -m "$2")"

if [ ! -d "$INPUT_DIR" ]; then
  echo "Error: Input directory does not exist."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Input : $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo

# 支持常见视频格式
VIDEO_EXTENSIONS="mp4 mkv mov avi flv webm m4v"

find "$INPUT_DIR" -type f | while read -r file; do
  ext="${file##*.}"
  ext_lower="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"

  if [[ " $VIDEO_EXTENSIONS " == *" $ext_lower "* ]]; then
    # 保持目录结构
    relative_path="${file#$INPUT_DIR/}"
    output_file="$OUTPUT_DIR/${relative_path%.*}.mp3"

    mkdir -p "$(dirname "$output_file")"

    echo "Converting: $relative_path"

    ffmpeg -loglevel error -y \
      -i "$file" \
      -vn \
      -c:a libmp3lame \
      -ab 192k \
      "$output_file" || echo "Failed: $relative_path"

  fi
done

echo
echo "Done."
