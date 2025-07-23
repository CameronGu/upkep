#!/bin/bash
# apt_update.sh - APT updates
run_apt_updates() {
    draw_box "$GREEN" "APT UPDATES"
    local start_time=$(date +%s)
    (sudo apt update && sudo apt upgrade -y) & spinner $! "Updating APT packages"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 0 ]]; then
        APT_STATUS="success"
        update_module_state "apt_update" "success" "APT packages updated successfully" "$duration"
    else
        APT_STATUS="failed"
        update_module_state "apt_update" "failed" "APT package update failed" "$duration"
    fi
}
