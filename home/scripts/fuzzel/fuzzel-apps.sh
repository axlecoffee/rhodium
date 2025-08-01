#!/usr/bin/env bash

set -euo pipefail

# --- Imports ---
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common/bootstrap.sh"

# --- Main Configuration ---
load_metadata "fuzzel" "apps"

# --- Configuration ---
PADDING_ARGS="35 20 20" # Column padding: name, type, categories

launch_app() {
  APP_DIR="$HOME/.local/share/applications"
  CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/$APP_NAME"
  CACHE_FILE="$CACHE_DIR/formatted_apps.cache"

  # Display from cache
  selected=$(cut -f1 "$CACHE_FILE" | fuzzel --dmenu --prompt="$PROMPT" -w 85)
  [[ -z "$selected" ]] && return

  # Find corresponding file from cache
  filename=$(awk -F'\t' -v sel="$selected" '$1 == sel { print $2; exit }' "$CACHE_FILE")

  if [[ -n "$filename" ]]; then
    (gtk-launch "$(basename "$filename" .desktop)" || true) >/dev/null 2>&1 &
  fi

}

main() {
  launch_app
}

main
