#!/bin/bash
# main.sh - Main entry point for upKep Linux Maintainer

BASE_DIR="$(dirname "$0")"
source "$BASE_DIR/core/config.sh"
source "$BASE_DIR/modules/core/utils.sh"
source "$BASE_DIR/modules/core/ascii_art.sh"
source "$BASE_DIR/core/state.sh"
source "$BASE_DIR/modules/core/apt_update.sh"
source "$BASE_DIR/modules/core/snap_update.sh"
source "$BASE_DIR/modules/core/flatpak_update.sh"
source "$BASE_DIR/modules/core/cleanup.sh"

# Initialize configuration system
init_config

# Initialize state management system
init_state

# ── Interval Configuration ───────────────────────────────────────────
# Get configuration values from YAML config files
UPDATE_INTERVAL_DAYS=$(get_global_config "defaults.update_interval" "7")
CLEANUP_INTERVAL_DAYS=$(get_global_config "defaults.cleanup_interval" "3")

# ── Status Variables ─────────────────────────────────────────────
# These variables track the outcome of each maintenance step
# (APT, Snap, Flatpak, Cleanup) during a single run. They are
# initialized to "skipped" and updated to "success" or "failed"
# by the respective update functions. `SKIP_NOTE` holds an
# optional message explaining why a step was skipped.
APT_STATUS="skipped"
SNAP_STATUS="skipped"
FLATPAK_STATUS="skipped"
CLEANUP_STATUS="skipped"
SKIP_NOTE=""

# ── Help and Version Functions ─────────────────────────────────────
show_help() {
    echo "upKep Linux Maintainer - Automated system maintenance tool"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show this help message"
    echo "  --version, -v       Show version information"
    echo "  --config            Show current configuration"
    echo "  --status            Show current system status"
    echo "  --force             Force run all operations (ignore intervals)"
    echo "  --dry-run           Show what would be done without executing"
    echo "  --setup             Run interactive setup wizard"
    echo "  --config-edit       Edit configuration interactively"
    echo "  --module-config     Configure modules interactively"
    echo "  --migrate           Check and run configuration migrations"
    echo "  --migration-history Show migration history"
    echo ""
    echo "Examples:"
    echo "  $0                  Run normal maintenance operations"
    echo "  $0 --help           Show this help"
    echo "  $0 --config         Show configuration"
    echo "  $0 --force          Force run all operations"
    echo "  $0 --setup          Run setup wizard"
    echo ""
    echo "Configuration:"
    echo "  Global config: ~/.upkep/config.yaml"
    echo "  Module configs: ~/.upkep/modules/"
}

show_version() {
    echo "upKep Linux Maintainer v0.1.0"
    echo "by CameronGu"
    echo ""
    echo "A comprehensive Linux system maintenance tool"
}

show_current_config() {
    echo "Current Configuration:"
    echo "======================"
    show_config "global"
    echo ""
    show_config "modules"
}

run_setup_wizard() {
    echo "Starting upKep Setup Wizard..."
    interactive_config "setup"
}

edit_config_interactively() {
    echo "Starting Interactive Configuration Editor..."
    interactive_config "global"
}

configure_modules_interactively() {
    echo "Starting Module Configuration..."
    interactive_config "modules"
}

# ── Argument Processing ───────────────────────────────────────────
INTERACTIVE_MODE=false

process_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            --config)
                show_current_config
                exit 0
                ;;
            --status)
                ascii_title
                show_current_status
                exit 0
                ;;
            --force)
                FORCE_RUN=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --setup)
                INTERACTIVE_MODE=true
                run_setup_wizard
                ;;
            --config-edit)
                INTERACTIVE_MODE=true
                edit_config_interactively
                ;;
            --module-config)
                INTERACTIVE_MODE=true
                configure_modules_interactively
                ;;
            --migrate)
                INTERACTIVE_MODE=true
                perform_migration
                exit 0
                ;;
            --migration-history)
                show_migration_history
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# ── Interval Checking Functions ─────────────────────────────────────
check_update_interval() {
    # Skip interval check if --force is used
    if [[ "${FORCE_RUN:-false}" == "true" ]]; then
        return 0
    fi

    load_state
    NOW=$(date +%s)
    DAYS_SINCE_UPDATE=$(( (NOW - UPDATE_LAST_RUN) / 86400 ))

    if [[ $DAYS_SINCE_UPDATE -lt $UPDATE_INTERVAL_DAYS ]]; then
        echo "Updates within interval ($DAYS_SINCE_UPDATE days < $UPDATE_INTERVAL_DAYS days) – skipped"
        return 1
    fi
    return 0
}

check_cleanup_interval() {
    # Skip interval check if --force is used
    if [[ "${FORCE_RUN:-false}" == "true" ]]; then
        return 0
    fi

    load_state
    NOW=$(date +%s)
    DAYS_SINCE_CLEANUP=$(( (NOW - CLEANUP_LAST_RUN) / 86400 ))

    if [[ $DAYS_SINCE_CLEANUP -lt $CLEANUP_INTERVAL_DAYS ]]; then
        echo "Cleanup within interval ($DAYS_SINCE_CLEANUP days < $CLEANUP_INTERVAL_DAYS days) – skipped"
        return 1
    fi
        return 0
}

main() {
    ascii_title

    # Validate configuration on startup
    if ! validate_startup_config; then
        echo ""
        echo "Configuration validation failed. Please fix the issues and try again."
        echo "Run 'upkep --setup' to reconfigure or 'upkep --config' to view current config."
        exit 1
    fi

    # Check for configuration migrations
    if check_migration_needed; then
        echo ""
        echo "Configuration migration is available."
        echo "Run with --migrate to upgrade your configuration."
        echo ""
    fi

    show_current_status

    # Check intervals and run operations accordingly
    UPDATE_SKIP_NOTE=$(check_update_interval)
    if [[ $? -eq 0 ]]; then
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            echo "DRY RUN: Would run APT updates"
            echo "DRY RUN: Would run Snap updates"
            echo "DRY RUN: Would run Flatpak updates"
        else
            run_apt_updates
            run_snap_updates
            run_flatpak_updates
        fi
    else
        draw_box "$YELLOW" "UPDATES SKIPPED" "$UPDATE_SKIP_NOTE"
    fi

    CLEANUP_SKIP_NOTE=$(check_cleanup_interval)
    if [[ $? -eq 0 ]]; then
        if [[ "${DRY_RUN:-false}" == "true" ]]; then
            echo "DRY RUN: Would run cleanup"
        else
            run_cleanup
        fi
    else
        draw_box "$YELLOW" "CLEANUP SKIPPED" "$CLEANUP_SKIP_NOTE"
    fi

    if [[ "${DRY_RUN:-false}" != "true" ]]; then
        save_state
    fi
    draw_summary
}

# Process command line arguments
process_args "$@"

# Run main function
if [[ "$INTERACTIVE_MODE" == "true" ]]; then
    # Interactive mode was used, exit after the interactive function completes
    exit 0
else
    # Run normal maintenance operations
    main
fi
