#!/bin/bash
# Migration script: 1.0.0 -> 2.0.0
# Generated on 2024-01-22

# Simple migration script for upgrading configuration from version 1.0.0 to 2.0.0

# Migration function
migrate_1_0_0_to_2_0_0() {
    local from_version="$1"
    local to_version="$2"
    
    echo "Starting migration from $from_version to $to_version..."
    
    # Set config file path
    local config_file="$HOME/.upkep/config.yaml"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file not found: $config_file"
        return 1
    fi
    
    # Create backup
    local backup_file="$HOME/.upkep/config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
    echo "Backup created: $backup_file"
    
    # Read current config
    local temp_config
    temp_config=$(mktemp)
    
    # Add version field and update structure
    cat > "$temp_config" << 'EOF'
version: 2.0.0

defaults:
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
    description: Perform system cleanup
EOF
    
    # Replace the config file
    mv "$temp_config" "$config_file"
    
    echo "Migration completed successfully!"
    echo "Configuration updated to version $to_version"
    echo "Backup saved to: $backup_file"
    
    return 0
}

# Run the migration
migrate_1_0_0_to_2_0_0 "$1" "$2" 