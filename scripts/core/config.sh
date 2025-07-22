#!/bin/bash

# upKep Configuration Management
# Handles YAML-based configuration files for global and module-specific settings

# Configuration file locations
CONFIG_DIR="$HOME/.upkep"
GLOBAL_CONFIG="$CONFIG_DIR/config.yaml"
MODULE_CONFIG_DIR="$CONFIG_DIR/modules"

# Default configuration values
DEFAULT_CONFIG="
global:
  log_level: info
  notifications: true
  dry_run: false
  parallel_execution: true
  max_parallel_modules: 4

defaults:
  update_interval: 7
  cleanup_interval: 3
  security_interval: 1

logging:
  file: ~/.upkep/logs/upkep.log
  max_size: 10MB
  max_files: 5
  format: json

modules:
  apt_update:
    enabled: true
    interval_days: 7
    description: \"Update APT packages and repositories\"
  snap_update:
    enabled: true
    interval_days: 7
    description: \"Update Snap packages\"
  flatpak_update:
    enabled: true
    interval_days: 7
    description: \"Update Flatpak packages\"
  cleanup:
    enabled: true
    interval_days: 3
    description: \"System cleanup operations\"
"

# Initialize configuration system
init_config() {
    mkdir -p "$CONFIG_DIR" "$MODULE_CONFIG_DIR"
    
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        echo "$DEFAULT_CONFIG" > "$GLOBAL_CONFIG"
        echo "Created default configuration at $GLOBAL_CONFIG"
    fi
}

# Get global configuration value
get_global_config() {
    local key="$1"
    local default_value="${2:-}"
    
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        # Use yq for proper YAML parsing if available
        if command -v yq >/dev/null 2>&1; then
            local value=$(yq eval ".$key" "$GLOBAL_CONFIG" 2>/dev/null)
            if [[ -n "$value" && "$value" != "null" ]]; then
                echo "$value"
            else
                echo "$default_value"
            fi
        else
            # Fallback to simple grep parsing for basic key-value pairs
            local value=$(grep "^[[:space:]]*$key:" "$GLOBAL_CONFIG" | head -1 | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
            else
                echo "$default_value"
            fi
        fi
    else
        echo "$default_value"
    fi
}

# Get module configuration value
get_module_config() {
    local module_name="$1"
    local key="$2"
    local default_value="${3:-}"
    
    local module_config="$MODULE_CONFIG_DIR/${module_name}.yaml"
    
    if [[ -f "$module_config" ]]; then
        # Use yq for proper YAML parsing if available
        if command -v yq >/dev/null 2>&1; then
            local value=$(yq eval ".$key" "$module_config" 2>/dev/null)
            if [[ -n "$value" && "$value" != "null" ]]; then
                echo "$value"
            else
                echo "$default_value"
            fi
        else
            # Fallback to simple grep parsing for basic key-value pairs
            local value=$(grep "^[[:space:]]*$key:" "$module_config" | head -1 | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
            else
                echo "$default_value"
            fi
        fi
    else
        echo "$default_value"
    fi
}

# Set global configuration value
set_global_config() {
    local key="$1"
    local value="$2"
    
    mkdir -p "$CONFIG_DIR"
    
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        # Update existing key or add new one
        if grep -q "^[[:space:]]*$key:" "$GLOBAL_CONFIG"; then
            sed -i "s/^[[:space:]]*$key:.*/$key: $value/" "$GLOBAL_CONFIG"
        else
            echo "$key: $value" >> "$GLOBAL_CONFIG"
        fi
    else
        echo "$key: $value" > "$GLOBAL_CONFIG"
    fi
}

# Set module configuration value
set_module_config() {
    local module_name="$1"
    local key="$2"
    local value="$3"
    
    mkdir -p "$MODULE_CONFIG_DIR"
    local module_config="$MODULE_CONFIG_DIR/${module_name}.yaml"
    
    if [[ -f "$module_config" ]]; then
        if grep -q "^[[:space:]]*$key:" "$module_config"; then
            sed -i "s/^[[:space:]]*$key:.*/$key: $value/" "$module_config"
        else
            echo "$key: $value" >> "$module_config"
        fi
    else
        echo "$key: $value" > "$module_config"
    fi
}

# Validate configuration
validate_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        echo "Configuration file not found: $config_file"
        return 1
    fi
    
    # Basic YAML syntax validation
    if command -v yamllint >/dev/null 2>&1; then
        yamllint "$config_file" >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "YAML syntax error in configuration file: $config_file"
            return 1
        fi
    fi
    
    return 0
}

# Show configuration
show_config() {
    local config_type="${1:-global}"
    
    case "$config_type" in
        "global")
            if [[ -f "$GLOBAL_CONFIG" ]]; then
                echo "Global Configuration ($GLOBAL_CONFIG):"
                cat "$GLOBAL_CONFIG"
            else
                echo "Global configuration file not found"
            fi
            ;;
        "modules")
            echo "Module Configurations:"
            if [[ -d "$MODULE_CONFIG_DIR" ]]; then
                for config_file in "$MODULE_CONFIG_DIR"/*.yaml; do
                    if [[ -f "$config_file" ]]; then
                        local module_name=$(basename "$config_file" .yaml)
                        echo "  $module_name:"
                        cat "$config_file" | sed 's/^/    /'
                    fi
                done
            fi
            ;;
        *)
            echo "Unknown configuration type: $config_type"
            echo "Available types: global, modules"
            ;;
    esac
}

# Export configuration for external tools
export_config() {
    local format="${1:-json}"
    local output_file="${2:-}"
    
    case "$format" in
        "json")
            # Convert YAML to JSON (requires yq or similar tool)
            if command -v yq >/dev/null 2>&1; then
                local json_data=$(yq eval -o=json "$GLOBAL_CONFIG" 2>/dev/null)
                if [[ -n "$output_file" ]]; then
                    echo "$json_data" > "$output_file"
                else
                    echo "$json_data"
                fi
            else
                echo "yq not found. Install yq for JSON export support."
                return 1
            fi
            ;;
        "yaml")
            if [[ -n "$output_file" ]]; then
                cp "$GLOBAL_CONFIG" "$output_file"
            else
                cat "$GLOBAL_CONFIG"
            fi
            ;;
        *)
            echo "Unsupported format: $format"
            echo "Supported formats: json, yaml"
            return 1
            ;;
    esac
} 

# Interactive configuration management
interactive_config() {
    local config_type="${1:-global}"
    
    # Check for dialog or whiptail
    local dialog_cmd=""
    if command -v dialog >/dev/null 2>&1; then
        dialog_cmd="dialog"
    elif command -v whiptail >/dev/null 2>&1; then
        dialog_cmd="whiptail"
    else
        echo "Error: Neither dialog nor whiptail is installed."
        echo "Please install one of them to use interactive configuration."
        echo "  Ubuntu/Debian: sudo apt install dialog"
        echo "  CentOS/RHEL: sudo yum install dialog"
        return 1
    fi
    
    case "$config_type" in
        "global")
            interactive_global_config "$dialog_cmd"
            ;;
        "modules")
            interactive_module_config "$dialog_cmd"
            ;;
        "setup")
            interactive_setup_wizard "$dialog_cmd"
            ;;
        *)
            echo "Unknown configuration type: $config_type"
            echo "Available types: global, modules, setup"
            return 1
            ;;
    esac
}

interactive_global_config() {
    local dialog_cmd="$1"
    local temp_file=$(mktemp)
    
    # Create a temporary config file for editing
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        cp "$GLOBAL_CONFIG" "$temp_file"
    else
        echo "$DEFAULT_CONFIG" > "$temp_file"
    fi
    
    while true; do
        # Show current config and options
        local choice=$($dialog_cmd --title "upKep Global Configuration" \
            --menu "Select an option:" 10 45 8 \
            "1" "Edit update intervals" \
            "2" "Edit logging settings" \
            "3" "Edit global settings" \
            "4" "View current config" \
            "5" "Reset to defaults" \
            "6" "Save and exit" \
            "7" "Exit without saving" 3>&1 1>&2 2>&3)
        
        case $choice in
            "1")
                edit_update_intervals "$dialog_cmd" "$temp_file"
                ;;
            "2")
                edit_logging_settings "$dialog_cmd" "$temp_file"
                ;;
            "3")
                edit_global_settings "$dialog_cmd" "$temp_file"
                ;;
            "4")
                view_config_file "$dialog_cmd" "$temp_file"
                ;;
            "5")
                reset_to_defaults "$dialog_cmd" "$temp_file"
                ;;
            "6")
                cp "$temp_file" "$GLOBAL_CONFIG"
                $dialog_cmd --title "Success" --msgbox "Configuration saved successfully!" 8 40
                rm "$temp_file"
                return 0
                ;;
            "7")
                rm "$temp_file"
                return 0
                ;;
            *)
                rm "$temp_file"
                return 1
                ;;
        esac
    done
}

edit_update_intervals() {
    local dialog_cmd="$1"
    local config_file="$2"
    
    # Get current values
    local update_interval=$(get_global_config "defaults.update_interval" "7")
    local cleanup_interval=$(get_global_config "defaults.cleanup_interval" "3")
    local security_interval=$(get_global_config "defaults.security_interval" "1")
    
    # Create form for editing
    local form_output=$($dialog_cmd --title "Update Intervals" \
        --form "Edit update intervals (in days):" 8 45 0 \
        "Update interval:" 1 1 "$update_interval" 1 20 8 0 \
        "Cleanup interval:" 2 1 "$cleanup_interval" 2 20 8 0 \
        "Security interval:" 3 1 "$security_interval" 3 20 8 0 3>&1 1>&2 2>&3)
    
    if [[ $? -eq 0 ]]; then
        # Parse form output
        local new_update_interval=$(echo "$form_output" | head -1)
        local new_cleanup_interval=$(echo "$form_output" | head -2 | tail -1)
        local new_security_interval=$(echo "$form_output" | tail -1)
        
        # Update config file
        if command -v yq >/dev/null 2>&1; then
            yq eval ".defaults.update_interval = $new_update_interval" -i "$config_file"
            yq eval ".defaults.cleanup_interval = $new_cleanup_interval" -i "$config_file"
            yq eval ".defaults.security_interval = $new_security_interval" -i "$config_file"
        else
            # Fallback to sed for simple updates
            sed -i "s/update_interval:.*/update_interval: $new_update_interval/" "$config_file"
            sed -i "s/cleanup_interval:.*/cleanup_interval: $new_cleanup_interval/" "$config_file"
            sed -i "s/security_interval:.*/security_interval: $new_security_interval/" "$config_file"
        fi
        
        $dialog_cmd --title "Success" --msgbox "Update intervals updated successfully!" 8 40
    fi
}

edit_logging_settings() {
    local dialog_cmd="$1"
    local config_file="$2"
    
    # Get current values
    local log_file=$(get_global_config "logging.file" "~/.upkep/logs/upkep.log")
    local max_size=$(get_global_config "logging.max_size" "10MB")
    local max_files=$(get_global_config "logging.max_files" "5")
    local format=$(get_global_config "logging.format" "json")
    
    # Create form for editing
    local form_output=$($dialog_cmd --title "Logging Settings" \
        --form "Edit logging settings:" 8 50 0 \
        "Log file:" 1 1 "$log_file" 1 20 20 0 \
        "Max size:" 2 1 "$max_size" 2 20 8 0 \
        "Max files:" 3 1 "$max_files" 3 20 8 0 \
        "Format:" 4 1 "$format" 4 20 8 0 3>&1 1>&2 2>&3)
    
    if [[ $? -eq 0 ]]; then
        # Parse form output
        local new_log_file=$(echo "$form_output" | head -1)
        local new_max_size=$(echo "$form_output" | head -2 | tail -1)
        local new_max_files=$(echo "$form_output" | head -3 | tail -1)
        local new_format=$(echo "$form_output" | tail -1)
        
        # Update config file
        if command -v yq >/dev/null 2>&1; then
            yq eval ".logging.file = \"$new_log_file\"" -i "$config_file"
            yq eval ".logging.max_size = \"$new_max_size\"" -i "$config_file"
            yq eval ".logging.max_files = $new_max_files" -i "$config_file"
            yq eval ".logging.format = \"$new_format\"" -i "$config_file"
        else
            # Fallback to sed for simple updates
            sed -i "s|file:.*|file: $new_log_file|" "$config_file"
            sed -i "s/max_size:.*/max_size: $new_max_size/" "$config_file"
            sed -i "s/max_files:.*/max_files: $new_max_files/" "$config_file"
            sed -i "s/format:.*/format: $new_format/" "$config_file"
        fi
        
        $dialog_cmd --title "Success" --msgbox "Logging settings updated successfully!" 8 40
    fi
}

edit_global_settings() {
    local dialog_cmd="$1"
    local config_file="$2"
    
    # Get current values
    local log_level=$(get_global_config "global.log_level" "info")
    local notifications=$(get_global_config "global.notifications" "true")
    local dry_run=$(get_global_config "global.dry_run" "false")
    local parallel_execution=$(get_global_config "global.parallel_execution" "true")
    local max_parallel_modules=$(get_global_config "global.max_parallel_modules" "4")
    
    # Create form for editing
    local form_output=$($dialog_cmd --title "Global Settings" \
        --form "Edit global settings:" 8 50 0 \
        "Log level:" 1 1 "$log_level" 1 20 8 0 \
        "Notifications:" 2 1 "$notifications" 2 20 8 0 \
        "Dry run:" 3 1 "$dry_run" 3 20 8 0 \
        "Parallel execution:" 4 1 "$parallel_execution" 4 20 8 0 \
        "Max parallel modules:" 5 1 "$max_parallel_modules" 5 20 8 0 3>&1 1>&2 2>&3)
    
    if [[ $? -eq 0 ]]; then
        # Parse form output
        local new_log_level=$(echo "$form_output" | head -1)
        local new_notifications=$(echo "$form_output" | head -2 | tail -1)
        local new_dry_run=$(echo "$form_output" | head -3 | tail -1)
        local new_parallel_execution=$(echo "$form_output" | head -4 | tail -1)
        local new_max_parallel_modules=$(echo "$form_output" | tail -1)
        
        # Update config file
        if command -v yq >/dev/null 2>&1; then
            yq eval ".global.log_level = \"$new_log_level\"" -i "$config_file"
            yq eval ".global.notifications = $new_notifications" -i "$config_file"
            yq eval ".global.dry_run = $new_dry_run" -i "$config_file"
            yq eval ".global.parallel_execution = $new_parallel_execution" -i "$config_file"
            yq eval ".global.max_parallel_modules = $new_max_parallel_modules" -i "$config_file"
        else
            # Fallback to sed for simple updates
            sed -i "s/log_level:.*/log_level: $new_log_level/" "$config_file"
            sed -i "s/notifications:.*/notifications: $new_notifications/" "$config_file"
            sed -i "s/dry_run:.*/dry_run: $new_dry_run/" "$config_file"
            sed -i "s/parallel_execution:.*/parallel_execution: $new_parallel_execution/" "$config_file"
            sed -i "s/max_parallel_modules:.*/max_parallel_modules: $new_max_parallel_modules/" "$config_file"
        fi
        
        $dialog_cmd --title "Success" --msgbox "Global settings updated successfully!" 8 40
    fi
}

view_config_file() {
    local dialog_cmd="$1"
    local config_file="$2"
    
    $dialog_cmd --title "Current Configuration" \
        --scrolltext --textbox "$config_file" 20 70
}

reset_to_defaults() {
    local dialog_cmd="$1"
    local config_file="$2"
    
    $dialog_cmd --title "Reset to Defaults" \
        --yesno "Are you sure you want to reset the configuration to defaults? This will overwrite all current settings." 8 60
    
    if [[ $? -eq 0 ]]; then
        echo "$DEFAULT_CONFIG" > "$config_file"
        $dialog_cmd --title "Success" --msgbox "Configuration reset to defaults successfully!" 8 40
    fi
}

interactive_module_config() {
    local dialog_cmd="$1"
    
    # Get list of available modules
    local modules=()
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        for config_file in "$MODULE_CONFIG_DIR"/*.yaml; do
            if [[ -f "$config_file" ]]; then
                local module_name=$(basename "$config_file" .yaml)
                modules+=("$module_name")
            fi
        done
    fi
    
    # Add default modules if none exist
    if [[ ${#modules[@]} -eq 0 ]]; then
        modules=("apt_update" "snap_update" "flatpak_update" "cleanup")
    fi
    
    while true; do
        # Create module selection menu with descriptions
        local menu_items=()
        for module in "${modules[@]}"; do
            local description=$(get_module_config "$module" "description" "Module configuration for $module")
            local enabled=$(get_module_config "$module" "enabled" "true")
            local status=""
            if [[ "$enabled" == "true" ]]; then
                status="[ENABLED]"
            else
                status="[DISABLED]"
            fi
            # Truncate description if too long
            if [[ ${#description} -gt 25 ]]; then
                description="${description:0:22}..."
            fi
            menu_items+=("$module" "$status - $description")
        done
        
        # Add navigation options
        menu_items+=("done" "Finish module configuration")
        
        local choice=$($dialog_cmd --title "Module Configuration" \
            --menu "Select a module to configure:\n\nCurrent modules and their status:" 12 50 6 "${menu_items[@]}" 3>&1 1>&2 2>&3)
        
        if [[ -n "$choice" && "$choice" != "done" ]]; then
            edit_module_config "$dialog_cmd" "$choice"
        else
            break
        fi
    done
}

edit_module_config() {
    local dialog_cmd="$1"
    local module_name="$2"
    local module_config="$MODULE_CONFIG_DIR/${module_name}.yaml"
    local temp_file=$(mktemp)
    
    # Create or load module config
    if [[ -f "$module_config" ]]; then
        cp "$module_config" "$temp_file"
    else
        # Create default module config
        cat > "$temp_file" << EOF
enabled: true
interval_days: 7
description: "Module configuration for $module_name"
EOF
    fi
    
    # Get current values
    local enabled=$(get_module_config "$module_name" "enabled" "true")
    local interval_days=$(get_module_config "$module_name" "interval_days" "7")
    local description=$(get_module_config "$module_name" "description" "Module configuration for $module_name")
    
    # Show current module info
    $dialog_cmd --title "Configure $module_name" \
        --msgbox "Configuring module: $module_name\n\nCurrent settings:\n• Enabled: $enabled\n• Interval: $interval_days days\n• Description: $description\n\nPress OK to edit these settings." 10 50
    
    if [[ $? -ne 0 ]]; then
        rm "$temp_file"
        return 1
    fi
    
    # Create form for editing with better layout and sizing
    local form_output=$($dialog_cmd --title "Configure $module_name" \
        --form "Edit module settings for $module_name:" 8 45 0 \
        "Enabled (true/false):" 1 1 "$enabled" 1 20 8 0 \
        "Interval (days):" 2 1 "$interval_days" 2 20 8 0 \
        "Description:" 3 1 "$description" 3 20 20 0 3>&1 1>&2 2>&3)
    
    if [[ $? -eq 0 ]]; then
        # Parse form output
        local new_enabled=$(echo "$form_output" | head -1)
        local new_interval_days=$(echo "$form_output" | head -2 | tail -1)
        local new_description=$(echo "$form_output" | tail -1)
        
        # Update config file
        if command -v yq >/dev/null 2>&1; then
            yq eval ".enabled = $new_enabled" -i "$temp_file"
            yq eval ".interval_days = $new_interval_days" -i "$temp_file"
            yq eval ".description = \"$new_description\"" -i "$temp_file"
        else
            # Fallback to sed for simple updates
            sed -i "s/enabled:.*/enabled: $new_enabled/" "$temp_file"
            sed -i "s/interval_days:.*/interval_days: $new_interval_days/" "$temp_file"
            sed -i "s/description:.*/description: $new_description/" "$temp_file"
        fi
        
        # Save to module config
        mkdir -p "$MODULE_CONFIG_DIR"
        cp "$temp_file" "$module_config"
        
        # Show updated settings
        $dialog_cmd --title "Configuration Saved" \
            --msgbox "Module '$module_name' configuration updated:\n\n• Enabled: $new_enabled\n• Interval: $new_interval_days days\n• Description: $new_description\n\nPress OK to continue." 10 50
    fi
    
    rm "$temp_file"
}

interactive_setup_wizard() {
    local dialog_cmd="$1"
    
    $dialog_cmd --title "upKep Setup Wizard" \
        --msgbox "Welcome to upKep Linux Maintainer!\n\nThis wizard will help you configure upKep for your system.\n\nPress OK to continue." 10 50
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Initialize configuration
    init_config
    
    # Step 1: System Information
    $dialog_cmd --title "System Information" \
        --msgbox "upKep will help you maintain your Linux system by:\n\n• Updating APT packages and repositories\n• Updating Snap packages\n• Updating Flatpak packages\n• Performing system cleanup\n\nAll operations are scheduled based on configurable intervals.\n\nPress OK to configure update intervals." 12 60
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Step 2: Configure update intervals
    local temp_file=$(mktemp)
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        cp "$GLOBAL_CONFIG" "$temp_file"
    else
        echo "$DEFAULT_CONFIG" > "$temp_file"
    fi
    
    $dialog_cmd --title "Update Intervals" \
        --msgbox "Let's configure how often upKep should run updates.\n\n• Update interval: How often to check for package updates\n• Cleanup interval: How often to perform system cleanup\n• Security interval: How often to check for security updates\n\nPress OK to configure these intervals." 12 60
    
    if [[ $? -eq 0 ]]; then
        edit_update_intervals "$dialog_cmd" "$temp_file"
    fi
    
    # Step 3: Ask about module-specific configuration
    $dialog_cmd --title "Module Configuration" \
        --yesno "The intervals you just set are the default intervals for all modules.\n\nWould you like to configure individual modules?\n\nThis allows you to:\n• Enable/disable specific modules\n• Set different intervals for each module\n• Add custom descriptions\n\nThis is optional - you can skip this and use the default settings.\n\nPress 'Yes' to configure modules, or 'No' to skip." 15 60
    
    if [[ $? -eq 0 ]]; then
        interactive_module_config "$dialog_cmd"
    fi
    
    # Step 4: Configure logging (optional)
    $dialog_cmd --title "Logging Configuration" \
        --yesno "Would you like to configure logging settings?\n\nupKep can log its activities to help you track what was done and when.\n\nPress 'Yes' to configure logging, or 'No' to use default settings." 12 60
    
    if [[ $? -eq 0 ]]; then
        edit_logging_settings "$dialog_cmd" "$temp_file"
    fi
    
    # Final confirmation before saving
    $dialog_cmd --title "Save Configuration" \
        --yesno "Setup is complete!\n\nWould you like to save the configuration?\n\nPress 'Yes' to save and finish setup, or 'No' to cancel." 10 50
    
    if [[ $? -eq 0 ]]; then
        # Save configuration
        cp "$temp_file" "$GLOBAL_CONFIG"
        rm "$temp_file"
        
        $dialog_cmd --title "Setup Complete" \
            --msgbox "upKep has been configured successfully!\n\nConfiguration files are stored in:\n~/.upkep/\n\nYou can now run upKep to maintain your system:\n\n  bash scripts/main.sh\n\nTo modify settings later, use:\n  bash scripts/main.sh --config-edit" 15 60
    else
        rm "$temp_file"
        $dialog_cmd --title "Setup Cancelled" \
            --msgbox "Setup was cancelled. No changes were saved.\n\nYou can run the setup wizard again anytime with:\n  bash scripts/main.sh --setup" 10 50
    fi
} 