#!/bin/bash
# cleanup.sh - System cleanup
run_cleanup() {
    draw_box "$GREEN" "SYSTEM CLEANUP"
    (sudo apt autoremove -y && sudo apt clean) & spinner $! "Running cleanup tasks"
    if [[ $? -eq 0 ]]; then
        CLEANUP_STATUS="success"
        update_cleanup_state
    else
        CLEANUP_STATUS="failed"
    fi
}
