#!/usr/bin/env bash

BOOT_ID=$(cat /proc/sys/kernel/random/boot_id)
BOOT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

LOG_DIR="/home/spreadzhao/.local/share/net-log"
# INTERFACE=$(ip route | awk '/^default/ {print $5; exit}')

mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/${BOOT_TIME}__${BOOT_ID}.log"

echo "BOOT_TIME=$BOOT_TIME" >> "$LOG_FILE"
echo "BOOT_ID=$BOOT_ID" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# exec /usr/bin/nethogs -a -C -b -t "$INTERFACE" >> "$LOG_FILE"
exec nethogs -a -C -b -t >> "$LOG_FILE"
