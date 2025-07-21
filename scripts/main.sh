#!/bin/bash
# main.sh - Main entry point for upKep Linux Maintainer

BASE_DIR="$(dirname "$0")"
source "$BASE_DIR/modules/utils.sh"
source "$BASE_DIR/modules/ascii_art.sh"
source "$BASE_DIR/modules/state.sh"
source "$BASE_DIR/modules/apt_update.sh"
source "$BASE_DIR/modules/snap_update.sh"
source "$BASE_DIR/modules/flatpak_update.sh"
source "$BASE_DIR/modules/cleanup.sh"

# ── Status Variables ─────────────────────────────────────────────
# These variables track the outcome of each maintenance step
# (APT, Snap, Flatpak, Cleanup) during a single run. They are
# initialized to "skipped" and updated to "success" or "failed"
# by the respective update functions. `SKIP_NOTE` holds an
# optional message explaining why a step was skipped.
APT_STATUS="skipped"
SNAP_STATUS="skipped"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="skipped"
SKIP_NOTE=""

main() {
    ascii_title
    show_current_status
    run_apt_updates
    run_snap_updates
    run_flatpak_updates
    run_cleanup
    save_state
    draw_summary
}

main "$@"
