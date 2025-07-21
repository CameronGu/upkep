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

# ── Interval Configuration ───────────────────────────────────────────
# Define minimum intervals between operations (in days)
UPDATE_INTERVAL_DAYS=7
CLEANUP_INTERVAL_DAYS=3

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

# ── Interval Checking Functions ─────────────────────────────────────
check_update_interval() {
    load_state
    NOW=$(date +%s)
    DAYS_SINCE_UPDATE=$(( (NOW - UPDATE_LAST_RUN) / 86400 ))
    
    if [[ $DAYS_SINCE_UPDATE -lt $UPDATE_INTERVAL_DAYS ]]; then
        echo "Updates within interval ($DAYS_SINCE_UPDATE days < $UPDATE_INTERVAL_DAYS days) – skipped"
        return 1
    fi
    return 0
}

check_cleanup_interval() {
    load_state
    NOW=$(date +%s)
    DAYS_SINCE_CLEANUP=$(( (NOW - CLEANUP_LAST_RUN) / 86400 ))
    
    if [[ $DAYS_SINCE_CLEANUP -lt $CLEANUP_INTERVAL_DAYS ]]; then
        echo "Cleanup within interval ($DAYS_SINCE_CLEANUP days < $CLEANUP_INTERVAL_DAYS days) – skipped"
        return 1
    fi
    return 0
}

main() {
    ascii_title
    show_current_status
    
    # Check intervals and run operations accordingly
    UPDATE_SKIP_NOTE=$(check_update_interval)
    if [[ $? -eq 0 ]]; then
        run_apt_updates
        run_snap_updates
        run_flatpak_updates
    else
        draw_box "$YELLOW" "UPDATES SKIPPED" "$UPDATE_SKIP_NOTE"
    fi
    
    CLEANUP_SKIP_NOTE=$(check_cleanup_interval)
    if [[ $? -eq 0 ]]; then
        run_cleanup
    else
        draw_box "$YELLOW" "CLEANUP SKIPPED" "$CLEANUP_SKIP_NOTE"
    fi
    
    save_state
    draw_summary
}

main "$@"
