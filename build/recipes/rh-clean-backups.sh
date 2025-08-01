#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# Cleans backup files
#

# --- Main Configuration ---
APP_NAME="rh-build"
APP_TITLE="Rhodium Build"
RECIPE="rh-clean-backups"

# --- Imports ---
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common"
source "$COMMON_DIR/bootstrap.sh"

# --- Functions ---
function main() {
  notify "$APP_TITLE" "$RECIPE:\n${NOTIFY_BULLET} This will remove all .backup and .bkp files. Press Ctrl+C in terminal to cancel."
  sleep 3

  count=$(find "${HOME}/.config" -type f \( -name "*.backup" -o -name "*.bkp" \) -delete -print | wc -l)
  notify "$APP_TITLE" "$RECIPE:\n${NOTIFY_BULLET} Removed $count backup files"
}

main "$@"
