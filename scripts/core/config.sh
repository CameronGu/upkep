#!/bin/bash
# config.sh - Configuration management for upKep (modular version)

# Source configuration modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source global configuration functions
if [[ -f "$SCRIPT_DIR/config/global.sh" ]]; then
    source "$SCRIPT_DIR/config/global.sh"
else
    echo "Error: Global configuration module not found: $SCRIPT_DIR/config/global.sh"
    exit 1
fi

# Source module configuration functions
if [[ -f "$SCRIPT_DIR/config/module.sh" ]]; then
    source "$SCRIPT_DIR/config/module.sh"
else
    echo "Error: Module configuration module not found: $SCRIPT_DIR/config/module.sh"
    exit 1
fi

# Source backup/restore functions
if [[ -f "$SCRIPT_DIR/config/backup.sh" ]]; then
    source "$SCRIPT_DIR/config/backup.sh"
else
    echo "Error: Backup configuration module not found: $SCRIPT_DIR/config/backup.sh"
    exit 1
fi

# Source migration functions
if [[ -f "$SCRIPT_DIR/config/migration.sh" ]]; then
    source "$SCRIPT_DIR/config/migration.sh"
else
    echo "Error: Migration configuration module not found: $SCRIPT_DIR/config/migration.sh"
    exit 1
fi

# Validate configuration schema
validate_config_schema() {
    local issues_found=0

    # Validate global config structure
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        local required_keys=("defaults" "logging" "notifications" "modules")

        for key in "${required_keys[@]}"; do
            if ! get_global_config "$key" "" >/dev/null 2>&1; then
                echo "Missing required global config key: $key"
                ((issues_found++))
            fi
        done
    fi

    # Validate module configs
    validate_module_configs

    if [[ $issues_found -eq 0 ]]; then
        echo "Configuration schema validation passed"
        return 0
    else
        echo "Configuration schema validation found $issues_found issue(s)"
        return 1
    fi
}

# Interactive configuration setup
interactive_config() {
    echo "=== upKep Interactive Configuration ==="
    echo ""

    # Initialize config if needed
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        echo "Initializing configuration..."
        init_config
    fi

    # Show current config
    show_config "global"
    echo ""

    # Interactive menu
    while true; do
        echo "Configuration Options:"
        echo "1. Edit global settings"
        echo "2. Edit module settings"
        echo "3. Validate configuration"
        echo "4. Backup configuration"
        echo "5. Restore configuration"
        echo "6. View configuration"
        echo "7. Reset to defaults"
        echo "8. Check for migrations"
        echo "9. Show migration history"
        echo "0. Exit"
        echo ""
        echo -n "Select option: "
        read -r choice

        case $choice in
            1) interactive_global_config_simple ;;
            2) interactive_module_config_simple ;;
            3) validate_config_schema ;;
            4) backup_config ;;
            5)
                echo "Enter backup path: "
                read -r backup_path
                restore_config "$backup_path"
                ;;
            6) show_config "global" ;;
            7) reset_to_defaults_simple ;;
            8) perform_migration ;;
            9) show_migration_history ;;
            0) break ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        echo ""
    done
}

# Simple interactive global config editor
interactive_global_config_simple() {
    echo "=== Global Configuration Editor ==="

    # Get current values
    local update_interval
    update_interval=$(get_global_config "defaults.update_interval" "7")
    local cleanup_interval
    cleanup_interval=$(get_global_config "defaults.cleanup_interval" "30")
    local log_level
    log_level=$(get_global_config "logging.level" "info")
    local notifications_enabled
    notifications_enabled=$(get_global_config "notifications.enabled" "true")

    echo "Current settings:"
    echo "1. Update interval: $update_interval days"
    echo "2. Cleanup interval: $cleanup_interval days"
    echo "3. Log level: $log_level"
    echo "4. Notifications: $notifications_enabled"
    echo "5. Back to main menu"
    echo ""

    echo -n "Select setting to edit (1-5): "
    read -r choice

    case $choice in
        1)
            echo -n "Enter new update interval (days): "
            read -r new_interval
            if [[ "$new_interval" =~ ^[0-9]+$ ]] && [[ $new_interval -ge 1 ]]; then
                set_global_config "defaults.update_interval" "$new_interval"
                echo "Update interval updated to $new_interval days"
            else
                echo "Invalid interval. Must be a positive number."
            fi
            ;;
        2)
            echo -n "Enter new cleanup interval (days): "
            read -r new_interval
            if [[ "$new_interval" =~ ^[0-9]+$ ]] && [[ $new_interval -ge 1 ]]; then
                set_global_config "defaults.cleanup_interval" "$new_interval"
                echo "Cleanup interval updated to $new_interval days"
            else
                echo "Invalid interval. Must be a positive number."
            fi
            ;;
        3)
            echo "Available log levels: debug, info, warn, error"
            echo -n "Enter new log level: "
            read -r new_level
            if [[ "$new_level" =~ ^(debug|info|warn|error)$ ]]; then
                set_global_config "logging.level" "$new_level"
                echo "Log level updated to $new_level"
            else
                echo "Invalid log level."
            fi
            ;;
        4)
            echo -n "Enable notifications? (true/false): "
            read -r new_setting
            if [[ "$new_setting" =~ ^(true|false)$ ]]; then
                set_global_config "notifications.enabled" "$new_setting"
                echo "Notifications updated to $new_setting"
            else
                echo "Invalid setting. Use 'true' or 'false'."
            fi
            ;;
        5) return ;;
        *) echo "Invalid option." ;;
    esac
}

# Simple interactive module config editor
interactive_module_config_simple() {
    echo "=== Module Configuration Editor ==="

    # List available modules
    echo "Available modules:"
    list_module_configs
    echo ""

    echo -n "Enter module name to edit (or 'back' to return): "
    read -r module_name

    if [[ "$module_name" == "back" ]]; then
        return
    fi

    if [[ -z "$module_name" ]]; then
        echo "No module name provided."
        return
    fi

    edit_module_config_simple "$module_name"
}

# Edit specific module configuration
edit_module_config_simple() {
    local module="$1"
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"

    if [[ ! -f "$module_config" ]]; then
        echo "Module configuration not found: $module"
        echo "Creating default configuration..."
        create_default_module_config "$module"
    fi

    # Get current values
    local enabled
    enabled=$(get_module_config "$module" "enabled" "true")
    local interval
    interval=$(get_module_config "$module" "interval_days" "7")
    local description
    description=$(get_module_config "$module" "description" "")

    echo "=== Module: $module ==="
    echo "Current settings:"
    echo "1. Enabled: $enabled"
    echo "2. Interval: $interval days"
    echo "3. Description: $description"
    echo "4. Back to module list"
    echo ""

    echo -n "Select setting to edit (1-4): "
    read -r choice

    case $choice in
        1)
            echo -n "Enable module? (true/false): "
            read -r new_enabled
            if [[ "$new_enabled" =~ ^(true|false)$ ]]; then
                set_module_config "$module" "enabled" "$new_enabled"
                echo "Module enabled setting updated to $new_enabled"
            else
                echo "Invalid setting. Use 'true' or 'false'."
            fi
            ;;
        2)
            echo -n "Enter new interval (days): "
            read -r new_interval
            if [[ "$new_interval" =~ ^[0-9]+$ ]] && [[ $new_interval -ge 1 ]] && [[ $new_interval -le 365 ]]; then
                set_module_config "$module" "interval_days" "$new_interval"
                echo "Interval updated to $new_interval days"
            else
                echo "Invalid interval. Must be 1-365 days."
            fi
            ;;
        3)
            echo -n "Enter new description: "
            read -r new_description
            set_module_config "$module" "description" "$new_description"
            echo "Description updated"
            ;;
        4) return ;;
        *) echo "Invalid option." ;;
    esac
}

# Reset configuration to defaults
reset_to_defaults_simple() {
    echo "This will reset your configuration to defaults."
    echo "Are you sure? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Reset cancelled."
        return
    fi

    # Backup current config
    auto_backup

    # Reset global config
    secure_file_create "$GLOBAL_CONFIG" "$DEFAULT_CONFIG" "600"
    echo "Global configuration reset to defaults"

    # Remove module configs
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        rm -rf "$MODULE_CONFIG_DIR"
        echo "Module configurations removed"
    fi

    echo "Configuration reset completed"
}

# View configuration file
view_config_file_simple() {
    local config_type="${1:-global}"

    case "$config_type" in
        "global")
            if [[ -f "$GLOBAL_CONFIG" ]]; then
                echo "=== Global Configuration File ==="
                cat "$GLOBAL_CONFIG"
            else
                echo "Global configuration file not found"
            fi
            ;;
        "module")
            local module="${2:-}"
            if [[ -z "$module" ]]; then
                echo "Module name required"
                return 1
            fi
            local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
            if [[ -f "$module_config" ]]; then
                echo "=== Module Configuration File: $module ==="
                cat "$module_config"
            else
                echo "Module configuration file not found: $module_config"
            fi
            ;;
        *)
            echo "Invalid config type. Use 'global' or 'module'"
            return 1
            ;;
    esac
}

# Interactive setup wizard
interactive_setup_wizard_simple() {
    echo "=== upKep Setup Wizard ==="
    echo "This wizard will help you configure upKep for first use."
    echo ""

    # Initialize configuration
    echo "Initializing configuration..."
    init_config
    echo ""

    # Basic settings
    echo "Basic Settings:"
    echo -n "Default update interval (days) [7]: "
    read -r update_interval
    update_interval=${update_interval:-7}
    set_global_config "defaults.update_interval" "$update_interval"

    echo -n "Default cleanup interval (days) [30]: "
    read -r cleanup_interval
    cleanup_interval=${cleanup_interval:-30}
    set_global_config "defaults.cleanup_interval" "$cleanup_interval"

    echo -n "Log level (debug/info/warn/error) [info]: "
    read -r log_level
    log_level=${log_level:-info}
    set_global_config "logging.level" "$log_level"

    echo -n "Enable notifications? (true/false) [true]: "
    read -r notifications
    notifications=${notifications:-true}
    set_global_config "notifications.enabled" "$notifications"

    echo ""
    echo "Configuration completed!"
    echo "You can run 'upkep config' to make further changes."
}