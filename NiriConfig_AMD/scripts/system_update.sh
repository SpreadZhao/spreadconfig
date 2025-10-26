#!/usr/bin/env bash

#
# ===============================================
# Script Name: system_update.sh
# Description:
#   This script sequentially runs system and package manager updates.
#   Each command is executed independently, with clear success/failure feedback.
#   Errors in one command do NOT stop the others from running.
#   The script will pause for input when commands (like paru) require root privileges.
#
# Usage:
#   chmod +x system_update.sh
#   ./system_update.sh
#
# ===============================================

# Enable strict error handling for internal checks (but not fatal for each command)
set -u  # treat unset variables as errors
set -o pipefail

# -----------------------------------------------
# Define update commands
# You can flexibly add more commands here.
# Format: "description|command"
# -----------------------------------------------
COMMANDS=(
  "System packages (paru)|paru -Syu"
  "Rust toolchain self-update|rustup self update"
  "Rust toolchain components|rustup update"
  "Cargo global packages|cargo install-update -ag"
  "Python pipx packages|pipx upgrade-all"
  "Global npm packages|npm update -g"
)

# -----------------------------------------------
# Colors for visual feedback
# -----------------------------------------------
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# -----------------------------------------------
# Function: run_command
# Executes a command and prints status message.
# Arguments:
#   $1 -> description
#   $2 -> actual command
# -----------------------------------------------
run_command() {
  local desc="$1"
  local cmd="$2"

  echo -e "${YELLOW}==> Running: ${desc}${RESET}"
  echo "Command: ${cmd}"
  echo "---------------------------------------------"

  # Run the command (allow user interaction if needed)
  eval "$cmd"
  local status=$?

  if [ $status -eq 0 ]; then
    echo -e "${GREEN}✓ SUCCESS:${RESET} ${desc}"
  else
    echo -e "${RED}✗ FAILED:${RESET} ${desc} (exit code: $status)"
  fi

  echo "---------------------------------------------"
  echo
}

# -----------------------------------------------
# Main execution loop
# -----------------------------------------------
echo "=============================================="
echo "        🧩 Unified Update Script"
echo "=============================================="
echo

for entry in "${COMMANDS[@]}"; do
  IFS='|' read -r desc cmd <<< "$entry"
  run_command "$desc" "$cmd"
done

echo "=============================================="
echo -e "${GREEN}All update commands processed.${RESET}"
echo "=============================================="
