#!/bin/bash
# snap_update.sh - Snap updates
run_snap_updates() {
    draw_box "$GREEN" "SNAP UPDATES"
    (sudo snap refresh) & spinner $! "Refreshing Snap packages"
    [[ $? -eq 0 ]] && SNAP_STATUS="success" || SNAP_STATUS="failed"
}
