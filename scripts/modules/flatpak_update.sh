#!/bin/bash
# flatpak_update.sh - Flatpak updates
run_flatpak_updates() {
    draw_box "$GREEN" "FLATPAK UPDATES"
    (flatpak update -y) & spinner $! "Updating Flatpak packages"
    [[ $? -eq 0 ]] && FLATPAK_STATUS="success" || FLATPAK_STATUS="failed"
}
