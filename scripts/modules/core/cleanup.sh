#!/bin/bash
# cleanup.sh - System cleanup
run_cleanup() {
    draw_box "$GREEN" "SYSTEM CLEANUP"
    local start_time=$(date +%s)
    (sudo apt autoremove -y && sudo apt clean) & spinner $! "Running cleanup tasks"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 0 ]]; then
        CLEANUP_STATUS="success"
        update_module_state "cleanup" "success" "System cleanup completed successfully" "$duration"
    else
        CLEANUP_STATUS="failed"
        update_module_state "cleanup" "failed" "System cleanup failed" "$duration"
    fi
}
