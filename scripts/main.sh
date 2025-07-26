#!/bin/bash
# main.sh - Main entry point for upKep Linux Maintainer

BASE_DIR="$(dirname "$0")"
source "$BASE_DIR/core/config_simple.sh"
source "$BASE_DIR/modules/core/utils.sh"
source "$BASE_DIR/modules/core/ascii_art.sh"
source "$BASE_DIR/core/state.sh"
source "$BASE_DIR/modules/core/apt_update.sh"
source "$BASE_DIR/modules/core/snap_update.sh"
source "$BASE_DIR/modules/core/flatpak_update.sh"
source "$BASE_DIR/modules/core/cleanup.sh"
source "$BASE_DIR/core/cli.sh"

# Initialize simplified configuration system
init_simple_config

# Initialize state management system
init_state

# ── Interval Configuration ───────────────────────────────────────────
# Get configuration values using simplified system
UPDATE_INTERVAL_DAYS=$(get_update_interval)
CLEANUP_INTERVAL_DAYS=$(get_cleanup_interval)

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

# ── CLI Routing and Compatibility Functions ────────────────────────
# Detect if arguments look like subcommands or legacy flags
is_subcommand() {
    local first_arg="$1"
    case "$first_arg" in
        run|status|config|list-modules|create-module|validate-module|test-module|help|version|colorblind)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Map legacy flags to subcommands for backward compatibility
map_legacy_to_subcommand() {
    local args=("$@")

    # Check for legacy flags and convert to subcommands
    for arg in "${args[@]}"; do
        case "$arg" in
            --help|-h)
                echo "help"
                return 0
                ;;
            --version|-v)
                echo "version"
                return 0
                ;;
            --config)
                echo "config --show"
                return 0
                ;;
            --status)
                echo "status"
                return 0
                ;;
        esac
    done

    # If no legacy flags found, default to run command
    echo "run $*"
}

# ── Legacy Functions (Preserved for Backward Compatibility) ─────────
show_help() {
    echo "upKep Linux Maintainer - Automated system maintenance tool"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  run              Execute maintenance operations (default)"
    echo "  status           Display current status"
    echo "  config           Manage configuration"
    echo "  list-modules     List available modules"
    echo "  create-module    Create a new module"
    echo "  validate-module  Validate a module"
    echo "  help             Show this help message"
    echo ""
    echo "Legacy Options (backward compatibility):"
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
    echo "  --colorblind, -c    Enable colorblind-friendly colors"
    echo "  --no-colorblind     Disable colorblind mode"
    echo ""
    echo "Examples:"
    echo "  $0                  Run normal maintenance operations"
    echo "  $0 run --force      Force run all operations"
    echo "  $0 status           Show current status"
    echo "  $0 config --show    Show configuration"
    echo "  $0 help run         Show detailed help for run command"
    echo ""
    echo "For detailed help on commands, use: $0 help <command>"
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

# ── Legacy Argument Processing (Preserved) ──────────────────────────
INTERACTIVE_MODE=false

process_legacy_args() {
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
            --colorblind|-c)
                export UPKEP_COLORBLIND=1
                echo "✅ Colorblind mode enabled for this session"
                shift
                ;;
            --no-colorblind)
                unset UPKEP_COLORBLIND
                echo "✅ Colorblind mode disabled for this session"
                shift
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

# ── Main Execution Function (Preserved) ─────────────────────────────
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

# ── CLI Entry Point ─────────────────────────────────────────────────
# Determine whether to use new CLI framework or legacy processing
if [[ $# -eq 0 ]]; then
    # No arguments - run default maintenance
    main
elif is_subcommand "$1"; then
    # New subcommand format - use CLI framework
    parse_args "$@"
else
    # Legacy flag format - use legacy processing for backward compatibility
    process_legacy_args "$@"

    # Run main function if no interactive mode was triggered
    if [[ "$INTERACTIVE_MODE" == "false" ]]; then
        main
    fi
fi
