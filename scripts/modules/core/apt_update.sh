#!/bin/bash
# apt_update.sh - APT updates
run_apt_updates() {
    draw_box "$GREEN" "APT UPDATES"
    (sudo apt update && sudo apt upgrade -y) & spinner $! "Updating APT packages"
    if [[ $? -eq 0 ]]; then
        APT_STATUS="success"
        update_apt_state
    else
        APT_STATUS="failed"
    fi
}
