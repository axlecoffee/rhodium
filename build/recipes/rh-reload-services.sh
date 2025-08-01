#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# Reloads user services
#

# --- Main Configuration ---
APP_NAME="rh-build"
APP_TITLE="Rhodium Build"
RECIPE="rh-reload-services"

# --- Imports ---
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common"
source "$COMMON_DIR/bootstrap.sh"

# --- Functions ---
function main() {
  notify "$APP_TITLE" "$RECIPE:\n${NOTIFY_BULLET} Reloading User Services..."
  systemctl --user daemon-reload
  if command -v niri >/dev/null 2>&1; then niri msg action do-screen-transition --delay-ms 800 2>/dev/null || true; fi
  for service in rh-swaybg rh-waybar; do systemctl --user restart "$service.service" || true; done
  makoctl reload
  notify "$APP_TITLE" "$RECIPE:\n${NOTIFY_BULLET} Reloaded User Services"
}

main "$@"
