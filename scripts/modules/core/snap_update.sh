#!/bin/bash
# snap_update.sh - Snap updates
run_snap_updates() {
    draw_box "$GREEN" "SNAP UPDATES"
    local start_time=$(date +%s)
    (sudo snap refresh) & spinner $! "Refreshing Snap packages"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 0 ]]; then
        SNAP_STATUS="success"
        update_module_state "snap_update" "success" "Snap packages refreshed successfully" "$duration"
    else
        SNAP_STATUS="failed"
        update_module_state "snap_update" "failed" "Snap package refresh failed" "$duration"
    fi
}
