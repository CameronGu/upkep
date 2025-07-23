#!/bin/bash
# flatpak_update.sh - Flatpak updates
run_flatpak_updates() {
    draw_box "$GREEN" "FLATPAK UPDATES"
    local start_time=$(date +%s)
    (flatpak update -y) & spinner $! "Updating Flatpak packages"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 0 ]]; then
        FLATPAK_STATUS="success"
        update_module_state "flatpak_update" "success" "Flatpak packages updated successfully" "$duration"
    else
        FLATPAK_STATUS="failed"
        update_module_state "flatpak_update" "failed" "Flatpak package update failed" "$duration"
    fi
}
