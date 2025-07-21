#!/bin/bash
# cleanup.sh - System cleanup
run_cleanup() {
    draw_box "$GREEN" "SYSTEM CLEANUP"
    (sudo apt autoremove -y && sudo apt clean) & spinner $! "Running cleanup tasks"
    [[ $? -eq 0 ]] && CLEANUP_STATUS="success" || CLEANUP_STATUS="failed"
}
