#!/bin/bash
# apt_update.sh - APT updates
run_apt_updates() {
    draw_box "$GREEN" "APT UPDATES"
    (sudo apt update && sudo apt upgrade -y) & spinner $! "Updating APT packages"
    [[ $? -eq 0 ]] && APT_STATUS="success" || APT_STATUS="failed"
}
