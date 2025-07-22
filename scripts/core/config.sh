#!/bin/bash
# config.sh - Configuration management for upKep

# Configuration paths
GLOBAL_CONFIG="$HOME/.upkep/config.yaml"
MODULE_CONFIG_DIR="$HOME/.upkep/modules"

# Default configuration
DEFAULT_CONFIG="defaults:
  update_interval: 7
  cleanup_interval: 30
  security_interval: 1

logging:
  level: info
  file: ~/.upkep/upkep.log
  max_size: 10MB
  max_files: 5

notifications:
  enabled: true

dry_run: false
parallel_execution: true

modules:
  apt_update:
    enabled: true
    interval_days: 7
    description: Update APT packages and repositories
  snap_update:
    enabled: true
    interval_days: 7
    description: Update Snap packages
  flatpak_update:
    enabled: true
    interval_days: 7
    description: Update Flatpak packages
  cleanup:
    enabled: true
    interval_days: 30
    description: Perform system cleanup"

# Initialize configuration system
init_config() {
    # Use secure initialization
    secure_init_config
}

# Get global configuration value
get_global_config() {
    local key="$1"
    local default="$2"
    
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local value=$(yq eval ".$key" "$GLOBAL_CONFIG" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        else
            # Fallback to grep if yq is not available
            local value=$(grep "^[[:space:]]*${key//./[[:space:]]*}: " "$GLOBAL_CONFIG" | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    fi
    
    echo "$default"
}

# Set global configuration value
set_global_config() {
    local key="$1"
    local value="$2"
    
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        init_config
    fi
    
    if command -v yq >/dev/null 2>&1; then
        # Escape special characters in the value
        local escaped_value=$(echo "$value" | sed 's/"/\\"/g')
        yq eval ".$key = \"$escaped_value\"" -i "$GLOBAL_CONFIG" 2>/dev/null || {
            # Fallback if yq fails
            local temp_file=$(mktemp)
            cp "$GLOBAL_CONFIG" "$temp_file"
            
            # Convert dot notation to nested structure
            local path_parts=(${key//./ })
            local current_path=""
            local indent=""
            
            for part in "${path_parts[@]}"; do
                if [[ -z "$current_path" ]]; then
                    current_path="$part"
                    indent=""
                else
                    current_path="${current_path}.$part"
                    indent="  $indent"
                fi
                
                # Check if the path exists
                if ! grep -q "^${indent}${part}:" "$temp_file"; then
                    # Add the key if it doesn't exist
                    echo "${indent}${part}:" >> "$temp_file"
                fi
            done
            
            # Update the value
            sed -i "s/^${indent}${path_parts[-1]}:[[:space:]]*.*/${indent}${path_parts[-1]}: $escaped_value/" "$temp_file"
            
            mv "$temp_file" "$GLOBAL_CONFIG"
        }
    else
        # Fallback to sed if yq is not available
        local temp_file=$(mktemp)
        cp "$GLOBAL_CONFIG" "$temp_file"
        
        # Convert dot notation to nested structure
        local path_parts=(${key//./ })
        local current_path=""
        local indent=""
        
        for part in "${path_parts[@]}"; do
            if [[ -z "$current_path" ]]; then
                current_path="$part"
                indent=""
            else
                current_path="${current_path}.$part"
                indent="  $indent"
            fi
            
            # Check if the path exists
            if ! grep -q "^${indent}${part}:" "$temp_file"; then
                # Add the key if it doesn't exist
                echo "${indent}${part}:" >> "$temp_file"
            fi
        done
        
        # Update the value
        sed -i "s/^${indent}${path_parts[-1]}:[[:space:]]*.*/${indent}${path_parts[-1]}: $value/" "$temp_file"
        
        mv "$temp_file" "$GLOBAL_CONFIG"
    fi
}

# Get module configuration value
get_module_config() {
    local module="$1"
    local key="$2"
    local default="$3"
    
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    
    if [[ -f "$module_config" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local value=$(yq eval ".$key" "$module_config" 2>/dev/null)
            if [[ "$value" != "null" && -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        else
            # Fallback to grep if yq is not available
            local value=$(grep "^[[:space:]]*${key}:[[:space:]]*" "$module_config" | sed 's/.*:[[:space:]]*//')
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    fi
    
    echo "$default"
}

# Set module configuration value
set_module_config() {
    local module="$1"
    local key="$2"
    local value="$3"
    
    local module_config="$MODULE_CONFIG_DIR/${module}.yaml"
    
    # Create module config directory if it doesn't exist
    mkdir -p "$MODULE_CONFIG_DIR"
    chmod 700 "$MODULE_CONFIG_DIR"
    
    # Create module config file if it doesn't exist
    if [[ ! -f "$module_config" ]]; then
        local default_content="enabled: true
interval_days: 7
description: \"\""
        secure_file_create "$module_config" "$default_content" "600"
    fi
    
    if command -v yq >/dev/null 2>&1; then
        yq eval ".$key = \"$value\"" -i "$module_config"
    else
        # Fallback to sed if yq is not available
        local temp_file=$(mktemp)
        cp "$module_config" "$temp_file"
        
        # Update the value
        if grep -q "^[[:space:]]*${key}:" "$temp_file"; then
            sed -i "s/^[[:space:]]*${key}:[[:space:]]*.*/  ${key}: $value/" "$temp_file"
        else
            echo "  ${key}: $value" >> "$temp_file"
        fi
        
        mv "$temp_file" "$module_config"
    fi
}

# Show configuration
show_config() {
    local config_type="$1"
    
    case "$config_type" in
        "global")
            echo "Global Configuration:"
            echo "==================="
            if [[ -f "$GLOBAL_CONFIG" ]]; then
                cat "$GLOBAL_CONFIG"
            else
                echo "No global configuration file found."
            fi
            ;;
        "modules")
            echo "Module Configurations:"
            echo "====================="
            if [[ -d "$MODULE_CONFIG_DIR" ]]; then
                for module_file in "$MODULE_CONFIG_DIR"/*.yaml; do
                    if [[ -f "$module_file" ]]; then
                        local module_name=$(basename "$module_file" .yaml)
                        echo "Module: $module_name"
                        echo "----------------"
                        cat "$module_file"
                        echo ""
                    fi
                done
            else
                echo "No module configuration directory found."
            fi
            ;;
        *)
            echo "Unknown configuration type: $config_type"
            ;;
    esac
}

# =============================================================================
# SECURE SETTINGS HANDLING
# =============================================================================

# Secure file creation with proper permissions
secure_file_create() {
    local file_path="$1"
    local content="$2"
    local permissions="${3:-600}"
    
    # Create directory if it doesn't exist
    local dir_path=$(dirname "$file_path")
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
        chmod 700 "$dir_path"
    fi
    
    # Create file with atomic write
    local temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    
    # Set permissions and move atomically
    chmod "$permissions" "$temp_file"
    mv "$temp_file" "$file_path"
    
    echo "Created secure file: $file_path (permissions: $permissions)"
}

# Validate file permissions
validate_file_permissions() {
    local file_path="$1"
    local expected_permissions="${2:-600}"
    
    if [[ ! -f "$file_path" ]]; then
        echo "File does not exist: $file_path"
        return 1
    fi
    
    local current_permissions=$(stat -c "%a" "$file_path")
    if [[ "$current_permissions" != "$expected_permissions" ]]; then
        echo "WARNING: Incorrect permissions on $file_path (current: $current_permissions, expected: $expected_permissions)"
        return 1
    fi
    
    echo "Permissions OK: $file_path ($current_permissions)"
    return 0
}

# Repair file permissions
repair_permissions() {
    local file_path="$1"
    local expected_permissions="${2:-600}"
    
    if [[ ! -f "$file_path" ]]; then
        echo "File does not exist: $file_path"
        return 1
    fi
    
    local current_permissions=$(stat -c "%a" "$file_path")
    if [[ "$current_permissions" != "$expected_permissions" ]]; then
        echo "Repairing permissions on $file_path (from $current_permissions to $expected_permissions)"
        chmod "$expected_permissions" "$file_path"
        return 0
    fi
    
    echo "Permissions already correct: $file_path ($current_permissions)"
    return 0
}

# Validate and repair all configuration files
validate_all_config_permissions() {
    echo "Validating configuration file permissions..."
    
    local issues_found=0
    
    # Check global config
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        if ! validate_file_permissions "$GLOBAL_CONFIG" "600"; then
            repair_permissions "$GLOBAL_CONFIG" "600"
            ((issues_found++))
        fi
    fi
    
    # Check module configs
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f 2>/dev/null | while read -r module_file; do
            if ! validate_file_permissions "$module_file" "600"; then
                repair_permissions "$module_file" "600"
                ((issues_found++))
            fi
        done
    fi
    
    # Check directory permissions
    if [[ -d "$HOME/.upkep" ]]; then
        local dir_perms=$(stat -c "%a" "$HOME/.upkep")
        if [[ "$dir_perms" != "700" ]]; then
            echo "Repairing directory permissions on $HOME/.upkep (from $dir_perms to 700)"
            chmod 700 "$HOME/.upkep"
            ((issues_found++))
        fi
    fi
    
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        local module_dir_perms=$(stat -c "%a" "$MODULE_CONFIG_DIR")
        if [[ "$module_dir_perms" != "700" ]]; then
            echo "Repairing directory permissions on $MODULE_CONFIG_DIR (from $module_dir_perms to 700)"
            chmod 700 "$MODULE_CONFIG_DIR"
            ((issues_found++))
        fi
    fi
    
    if [[ $issues_found -eq 0 ]]; then
        echo "All configuration permissions are secure."
    else
        echo "Repaired $issues_found permission issues."
    fi
    
    return $issues_found
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

# Validate configuration schema
validate_config_schema() {
    local config_file="$1"
    local issues_found=0
    
    if [[ ! -f "$config_file" ]]; then
        echo "ERROR: Configuration file not found: $config_file"
        return 1
    fi
    
    # Check if yamllint is available for YAML validation
    if command -v yamllint >/dev/null 2>&1; then
        if ! yamllint "$config_file" >/dev/null 2>&1; then
            echo "WARNING: YAML syntax issues found in $config_file"
            ((issues_found++))
        fi
    fi
    
    # Basic structure validation
    local required_sections=("defaults" "logging" "notifications" "modules")
    for section in "${required_sections[@]}"; do
        if ! grep -q "^${section}:" "$config_file"; then
            echo "WARNING: Missing required section '$section' in $config_file"
            ((issues_found++))
        fi
    done
    
    # Validate critical values
    local update_interval=$(get_global_config "defaults.update_interval" "")
    if [[ -n "$update_interval" ]] && ! [[ "$update_interval" =~ ^[0-9]+$ ]]; then
        echo "WARNING: Invalid update_interval value: $update_interval (should be a number)"
        ((issues_found++))
    fi
    
    local cleanup_interval=$(get_global_config "defaults.cleanup_interval" "")
    if [[ -n "$cleanup_interval" ]] && ! [[ "$cleanup_interval" =~ ^[0-9]+$ ]]; then
        echo "WARNING: Invalid cleanup_interval value: $cleanup_interval (should be a number)"
        ((issues_found++))
    fi
    
    if [[ $issues_found -eq 0 ]]; then
        echo "Configuration validation passed: $config_file"
        return 0
    else
        echo "Configuration validation found $issues_found issue(s): $config_file"
        return 1
    fi
}

# Validate module configurations
validate_module_configs() {
    local issues_found=0
    
    if [[ ! -d "$MODULE_CONFIG_DIR" ]]; then
        return 0
    fi
    
    find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f 2>/dev/null | while read -r module_file; do
        local module_name=$(basename "$module_file" .yaml)
        
        # Check if yamllint is available
        if command -v yamllint >/dev/null 2>&1; then
            if ! yamllint "$module_file" >/dev/null 2>&1; then
                echo "WARNING: YAML syntax issues in module config: $module_name"
                ((issues_found++))
            fi
        fi
        
        # Validate module-specific values
        local enabled=$(get_module_config "$module_name" "enabled" "")
        if [[ -n "$enabled" ]] && [[ "$enabled" != "true" ]] && [[ "$enabled" != "false" ]]; then
            echo "WARNING: Invalid 'enabled' value in $module_name: $enabled (should be true/false)"
            ((issues_found++))
        fi
        
        local interval=$(get_module_config "$module_name" "interval_days" "")
        if [[ -n "$interval" ]] && ! [[ "$interval" =~ ^[0-9]+$ ]]; then
            echo "WARNING: Invalid 'interval_days' value in $module_name: $interval (should be a number)"
            ((issues_found++))
        fi
    done
    
    if [[ $issues_found -eq 0 ]]; then
        echo "Module configuration validation passed"
        return 0
    else
        echo "Module configuration validation found $issues_found issue(s)"
        return 1
    fi
}

# =============================================================================
# BACKUP AND RESTORE
# =============================================================================

# Backup configuration with timestamp
backup_config() {
    local backup_dir="$HOME/.upkep/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/config_backup_$timestamp.tar.gz"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    chmod 700 "$backup_dir"
    
    # Create backup
    if [[ -f "$GLOBAL_CONFIG" ]] || [[ -d "$MODULE_CONFIG_DIR" ]]; then
        tar -czf "$backup_file" -C "$HOME/.upkep" config.yaml modules/ 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "Configuration backed up to: $backup_file"
            
            # Rotate old backups (keep last 5)
            local backup_count=$(find "$backup_dir" -name "config_backup_*.tar.gz" | wc -l)
            if [[ $backup_count -gt 5 ]]; then
                find "$backup_dir" -name "config_backup_*.tar.gz" -printf '%T@ %p\n' | sort -n | head -n $((backup_count - 5)) | cut -d' ' -f2- | xargs rm -f
                echo "Rotated old backups (kept last 5)"
            fi
        else
            echo "ERROR: Failed to create backup"
            return 1
        fi
    else
        echo "No configuration files to backup"
    fi
}

# Restore configuration from backup
restore_config() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi
    
    # Validate backup file
    if ! tar -tzf "$backup_file" >/dev/null 2>&1; then
        echo "ERROR: Invalid backup file: $backup_file"
        return 1
    fi
    
    # Create temporary directory for extraction
    local temp_dir=$(mktemp -d)
    
    # Extract backup
    tar -xzf "$backup_file" -C "$temp_dir" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to extract backup"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Validate extracted configuration
    if [[ -f "$temp_dir/config.yaml" ]]; then
        if ! validate_config_schema "$temp_dir/config.yaml"; then
            echo "ERROR: Backup contains invalid configuration"
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    # Create backup of current config before restoration
    backup_config
    
    # Restore configuration
    if [[ -f "$temp_dir/config.yaml" ]]; then
        cp "$temp_dir/config.yaml" "$GLOBAL_CONFIG"
        chmod 600 "$GLOBAL_CONFIG"
    fi
    
    if [[ -d "$temp_dir/modules" ]]; then
        rm -rf "$MODULE_CONFIG_DIR"
        cp -r "$temp_dir/modules" "$MODULE_CONFIG_DIR"
        chmod 700 "$MODULE_CONFIG_DIR"
        find "$MODULE_CONFIG_DIR" -name "*.yaml" -exec chmod 600 {} \;
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo "Configuration restored from: $backup_file"
    echo "Previous configuration backed up automatically"
}

# List available backups
list_backups() {
    local backup_dir="$HOME/.upkep/backups"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "No backups found"
        return 0
    fi
    
    local backups=$(find "$backup_dir" -name "config_backup_*.tar.gz" -printf '%T@ %p\n' | sort -n)
    
    if [[ -z "$backups" ]]; then
        echo "No backups found"
        return 0
    fi
    
    echo "Available backups:"
    echo "=================="
    echo "$backups" | while read -r timestamp file; do
        local date_str=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S")
        local size=$(du -h "$file" | cut -f1)
        echo "$date_str - $size - $(basename "$file")"
    done
}

# Secure initialization with permission validation
secure_init_config() {
    echo "Initializing secure configuration system..."
    
    # Create configuration directory with secure permissions
    mkdir -p "$HOME/.upkep"
    chmod 700 "$HOME/.upkep"
    
    mkdir -p "$MODULE_CONFIG_DIR"
    chmod 700 "$MODULE_CONFIG_DIR"
    
    # Create default global config if it doesn't exist
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        secure_file_create "$GLOBAL_CONFIG" "$DEFAULT_CONFIG" "600"
        echo "Created secure default configuration at $GLOBAL_CONFIG"
    else
        # Validate existing config permissions
        validate_file_permissions "$GLOBAL_CONFIG" "600"
        
        # Validate configuration schema
        echo "Validating configuration schema..."
        validate_config_schema "$GLOBAL_CONFIG"
    fi
    
    # Validate module configurations
    echo "Validating module configurations..."
    validate_module_configs
    
    # Validate all permissions
    validate_all_config_permissions
    
    # Create initial backup if config exists
    if [[ -f "$GLOBAL_CONFIG" ]] || [[ -d "$MODULE_CONFIG_DIR" ]]; then
        echo "Creating initial configuration backup..."
        backup_config
    fi
    
    echo "Secure configuration system initialized."
}

# =============================================================================
# INTERACTIVE CONFIGURATION MANAGEMENT
# =============================================================================

# Interactive configuration management
interactive_config() {
    local config_type="${1:-global}"
    
    case "$config_type" in
        "global")
            interactive_global_config_simple
            ;;
        "modules")
            interactive_module_config_simple
            ;;
        "setup")
            interactive_setup_wizard_simple
            ;;
        *)
            echo "Unknown configuration type: $config_type"
            echo "Available types: global, modules, setup"
            return 1
            ;;
    esac
}

# Simple text-based global configuration
interactive_global_config_simple() {
    echo "=== upKep Global Configuration ==="
    echo ""
    
    while true; do
        echo "Current configuration:"
        echo "1. Update interval: $(get_global_config "defaults.update_interval" "7") days"
        echo "2. Cleanup interval: $(get_global_config "defaults.cleanup_interval" "30") days"
        echo "3. Security interval: $(get_global_config "defaults.security_interval" "1") days"
        echo "4. Log level: $(get_global_config "logging.level" "info")"
        echo "5. Notifications: $(get_global_config "notifications.enabled" "true")"
        echo "6. Dry run mode: $(get_global_config "dry_run" "false")"
        echo "7. Parallel execution: $(get_global_config "parallel_execution" "true")"
        echo ""
        echo "Options:"
        echo "a) Edit update intervals"
        echo "b) Edit logging settings"
        echo "c) Edit global settings"
        echo "v) View current config file"
        echo "r) Reset to defaults"
        echo "s) Save and exit"
        echo "q) Quit without saving"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            a|A)
                edit_update_intervals_simple
                ;;
            b|B)
                edit_logging_settings_simple
                ;;
            c|C)
                edit_global_settings_simple
                ;;
            v|V)
                view_config_file_simple
                ;;
            r|R)
                reset_to_defaults_simple
                ;;
            s|S)
                echo "Configuration saved."
                break
                ;;
            q|Q)
                echo "Exiting without saving changes."
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
        echo ""
    done
}

# Simple text-based update intervals editor
edit_update_intervals_simple() {
    echo "=== Edit Update Intervals ==="
    echo ""
    
    local update_interval=$(get_global_config "defaults.update_interval" "7")
    local cleanup_interval=$(get_global_config "defaults.cleanup_interval" "30")
    local security_interval=$(get_global_config "defaults.security_interval" "1")
    
    echo "Current intervals:"
    echo "1. Update interval: $update_interval days"
    echo "2. Cleanup interval: $cleanup_interval days"
    echo "3. Security interval: $security_interval days"
    echo ""
    
    read -p "Enter new update interval (days) [$update_interval]: " new_update
    if [[ -n "$new_update" ]]; then
        if [[ "$new_update" =~ ^[0-9]+$ ]] && [[ "$new_update" -ge 1 ]]; then
            set_global_config "defaults.update_interval" "$new_update"
            update_interval="$new_update"
            echo "Update interval set to $new_update days"
        else
            echo "Invalid value. Must be a positive number."
        fi
    fi
    
    read -p "Enter new cleanup interval (days) [$cleanup_interval]: " new_cleanup
    if [[ -n "$new_cleanup" ]]; then
        if [[ "$new_cleanup" =~ ^[0-9]+$ ]] && [[ "$new_cleanup" -ge 1 ]]; then
            set_global_config "defaults.cleanup_interval" "$new_cleanup"
            cleanup_interval="$new_cleanup"
            echo "Cleanup interval set to $new_cleanup days"
        else
            echo "Invalid value. Must be a positive number."
        fi
    fi
    
    read -p "Enter new security interval (days) [$security_interval]: " new_security
    if [[ -n "$new_security" ]]; then
        if [[ "$new_security" =~ ^[0-9]+$ ]] && [[ "$new_security" -ge 1 ]]; then
            set_global_config "defaults.security_interval" "$new_security"
            security_interval="$new_security"
            echo "Security interval set to $new_security days"
        else
            echo "Invalid value. Must be a positive number."
        fi
    fi
    
    echo "Intervals updated successfully!"
    echo ""
}

# Simple text-based logging settings editor
edit_logging_settings_simple() {
    echo "=== Edit Logging Settings ==="
    echo ""
    
    local log_level=$(get_global_config "logging.level" "info")
    local log_file=$(get_global_config "logging.file" "~/.upkep/upkep.log")
    local max_log_size=$(get_global_config "logging.max_size" "10MB")
    local max_log_files=$(get_global_config "logging.max_files" "5")
    
    echo "Current logging settings:"
    echo "1. Log level: $log_level"
    echo "2. Log file: $log_file"
    echo "3. Max log size: $max_log_size"
    echo "4. Max log files: $max_log_files"
    echo ""
    
    echo "Available log levels: debug, info, warn, error"
    read -p "Enter new log level [$log_level]: " new_level
    if [[ -n "$new_level" ]]; then
        if [[ "$new_level" =~ ^(debug|info|warn|error)$ ]]; then
            set_global_config "logging.level" "$new_level"
            log_level="$new_level"
            echo "Log level set to $new_level"
        else
            echo "Invalid log level. Must be debug, info, warn, or error."
        fi
    fi
    
    read -p "Enter log file path [$log_file]: " new_file
    if [[ -n "$new_file" ]]; then
        set_global_config "logging.file" "$new_file"
        log_file="$new_file"
        echo "Log file set to $new_file"
    fi
    
    read -p "Enter max log size (e.g., 10MB) [$max_log_size]: " new_size
    if [[ -n "$new_size" ]]; then
        set_global_config "logging.max_size" "$new_size"
        max_log_size="$new_size"
        echo "Max log size set to $new_size"
    fi
    
    read -p "Enter max log files (1-10) [$max_log_files]: " new_files
    if [[ -n "$new_files" ]]; then
        if [[ "$new_files" =~ ^[0-9]+$ ]] && [[ "$new_files" -ge 1 ]] && [[ "$new_files" -le 10 ]]; then
            set_global_config "logging.max_files" "$new_files"
            max_log_files="$new_files"
            echo "Max log files set to $new_files"
        else
            echo "Invalid value. Must be 1-10."
        fi
    fi
    
    echo "Logging settings updated successfully!"
    echo ""
}

# Simple text-based global settings editor
edit_global_settings_simple() {
    echo "=== Edit Global Settings ==="
    echo ""
    
    local notifications=$(get_global_config "notifications.enabled" "true")
    local dry_run=$(get_global_config "dry_run" "false")
    local parallel=$(get_global_config "parallel_execution" "true")
    
    echo "Current global settings:"
    echo "1. Notifications: $notifications"
    echo "2. Dry run mode: $dry_run"
    echo "3. Parallel execution: $parallel"
    echo ""
    
    read -p "Enable notifications? (y/n) [${notifications:0:1}]: " new_notifications
    if [[ -n "$new_notifications" ]]; then
        if [[ "$new_notifications" =~ ^[Yy]$ ]]; then
            set_global_config "notifications.enabled" "true"
            notifications="true"
            echo "Notifications enabled"
        elif [[ "$new_notifications" =~ ^[Nn]$ ]]; then
            set_global_config "notifications.enabled" "false"
            notifications="false"
            echo "Notifications disabled"
        else
            echo "Invalid input. Please enter y or n."
        fi
    fi
    
    read -p "Enable dry run mode? (y/n) [${dry_run:0:1}]: " new_dry_run
    if [[ -n "$new_dry_run" ]]; then
        if [[ "$new_dry_run" =~ ^[Yy]$ ]]; then
            set_global_config "dry_run" "true"
            dry_run="true"
            echo "Dry run mode enabled"
        elif [[ "$new_dry_run" =~ ^[Nn]$ ]]; then
            set_global_config "dry_run" "false"
            dry_run="false"
            echo "Dry run mode disabled"
        else
            echo "Invalid input. Please enter y or n."
        fi
    fi
    
    read -p "Enable parallel execution? (y/n) [${parallel:0:1}]: " new_parallel
    if [[ -n "$new_parallel" ]]; then
        if [[ "$new_parallel" =~ ^[Yy]$ ]]; then
            set_global_config "parallel_execution" "true"
            parallel="true"
            echo "Parallel execution enabled"
        elif [[ "$new_parallel" =~ ^[Nn]$ ]]; then
            set_global_config "parallel_execution" "false"
            parallel="false"
            echo "Parallel execution disabled"
        else
            echo "Invalid input. Please enter y or n."
        fi
    fi
    
    echo "Global settings updated successfully!"
    echo ""
}

# Simple text-based config file viewer
view_config_file_simple() {
    echo "=== Current Configuration File ==="
    echo ""
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        cat "$GLOBAL_CONFIG"
    else
        echo "No configuration file found. Using defaults."
    fi
    echo ""
    read -p "Press Enter to continue..."
}

# Simple text-based reset to defaults
reset_to_defaults_simple() {
    echo "=== Reset to Defaults ==="
    echo ""
    echo "This will reset all configuration to default values."
    read -p "Are you sure? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "$DEFAULT_CONFIG" > "$GLOBAL_CONFIG"
        echo "Configuration reset to defaults."
    else
        echo "Reset cancelled."
    fi
    echo ""
}

# Simple text-based module configuration
interactive_module_config_simple() {
    echo "=== Module Configuration ==="
    echo ""
    
    # Get list of available modules
    local modules=()
    for module_file in "$MODULE_CONFIG_DIR"/*.yaml; do
        if [[ -f "$module_file" ]]; then
            local module_name=$(basename "$module_file" .yaml)
                modules+=("$module_name")
            fi
        done
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        echo "No modules found."
        return 0
    fi
    
    echo "Available modules:"
    for i in "${!modules[@]}"; do
        local module="${modules[$i]}"
            local enabled=$(get_module_config "$module" "enabled" "true")
        local interval=$(get_module_config "$module" "interval_days" "7")
        echo "$((i+1)). $module (enabled: $enabled, interval: $interval days)"
    done
    echo ""
    
    read -p "Enter module number to configure (or q to quit): " choice
    if [[ "$choice" =~ ^[Qq]$ ]]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#modules[@]} ]]; then
        local selected_module="${modules[$((choice-1))]}"
        edit_module_config_simple "$selected_module"
    else
        echo "Invalid selection."
    fi
}

# Simple text-based module editor
edit_module_config_simple() {
    local module="$1"
    echo "=== Configure Module: $module ==="
    echo ""
    
    local enabled=$(get_module_config "$module" "enabled" "true")
    local interval=$(get_module_config "$module" "interval_days" "7")
    local description=$(get_module_config "$module" "description" "")
    
    echo "Current settings:"
    echo "1. Enabled: $enabled"
    echo "2. Interval: $interval days"
    echo "3. Description: $description"
    echo ""
    
    read -p "Enable this module? (y/n) [${enabled:0:1}]: " new_enabled
    if [[ -n "$new_enabled" ]]; then
        if [[ "$new_enabled" =~ ^[Yy]$ ]]; then
            set_module_config "$module" "enabled" "true"
            enabled="true"
            echo "Module enabled"
        elif [[ "$new_enabled" =~ ^[Nn]$ ]]; then
            set_module_config "$module" "enabled" "false"
            enabled="false"
            echo "Module disabled"
        else
            echo "Invalid input. Please enter y or n."
        fi
    fi
    
    read -p "Enter interval in days [$interval]: " new_interval
    if [[ -n "$new_interval" ]]; then
        if [[ "$new_interval" =~ ^[0-9]+$ ]] && [[ "$new_interval" -ge 1 ]]; then
            set_module_config "$module" "interval_days" "$new_interval"
            interval="$new_interval"
            echo "Interval set to $new_interval days"
        else
            echo "Invalid value. Must be a positive number."
        fi
    fi
    
    read -p "Enter description [$description]: " new_description
    if [[ -n "$new_description" ]]; then
        set_module_config "$module" "description" "$new_description"
        description="$new_description"
        echo "Description updated"
    fi
    
    echo "Module configuration updated successfully!"
    echo ""
}

# Simple text-based setup wizard
interactive_setup_wizard_simple() {
    echo "=== upKep Setup Wizard ==="
    echo ""
    echo "Welcome to upKep! This wizard will help you configure the basic settings."
    echo ""
    
    # Initialize configuration if it doesn't exist
    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        echo "Creating initial configuration..."
        init_config
    fi
    
    echo "Let's configure the basic settings:"
    echo ""
    
    # Configure update intervals
    echo "1. Update Intervals"
    edit_update_intervals_simple
    
    # Configure logging
    echo "2. Logging Settings"
    edit_logging_settings_simple
    
    # Configure global settings
    echo "3. Global Settings"
    edit_global_settings_simple
    
    echo "Setup complete! Your configuration has been saved."
    echo "You can run 'bash scripts/main.sh --config-edit' to modify settings later."
    echo ""
} 