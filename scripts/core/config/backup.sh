#!/bin/bash
# backup.sh - Configuration backup and restore for upKep

# Backup directory
BACKUP_DIR="$HOME/.upkep/backups"

# Backup configuration
backup_config() {
    local backup_name="${1:-}"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")

    if [[ -z "$backup_name" ]]; then
        backup_name="upkep_backup_${timestamp}"
    fi

    local backup_path="$BACKUP_DIR/$backup_name"
    mkdir -p "$backup_path"

    # Backup global config
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        cp "$GLOBAL_CONFIG" "$backup_path/global_config.yaml"
        echo "Backed up global configuration"
    fi

    # Backup module configs
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        local module_backup_dir="$backup_path/modules"
        mkdir -p "$module_backup_dir"

        while IFS= read -r -d '' file; do
            local module_name
            module_name=$(basename "$file")
            cp "$file" "$module_backup_dir/$module_name"
        done < <(find "$MODULE_CONFIG_DIR" -name "*.yaml" -type f -print0 2>/dev/null)

        echo "Backed up module configurations"
    fi

    # Create backup manifest
    local manifest_file="$backup_path/manifest.txt"
    {
        echo "upKep Configuration Backup"
        echo "Created: $(date)"
        echo "Backup Name: $backup_name"
        echo ""
        echo "Files included:"
        if [[ -f "$backup_path/global_config.yaml" ]]; then
            echo "- global_config.yaml"
        fi
        if [[ -d "$backup_path/modules" ]]; then
            while IFS= read -r -d '' file; do
                local module_name
                module_name=$(basename "$file")
                echo "- modules/$module_name"
            done < <(find "$backup_path/modules" -name "*.yaml" -type f -print0 2>/dev/null)
        fi
    } > "$manifest_file"

    # Set secure permissions
    chmod 700 "$backup_path"
    find "$backup_path" -type f -exec chmod 600 {} \;

    echo "Configuration backup completed: $backup_path"
    echo "Backup manifest: $manifest_file"
}

# Restore configuration
restore_config() {
    local backup_path="$1"
    local confirm="${2:-false}"

    if [[ ! -d "$backup_path" ]]; then
        echo "Error: Backup directory not found: $backup_path"
        return 1
    fi

    # Check for manifest file
    if [[ ! -f "$backup_path/manifest.txt" ]]; then
        echo "Error: Invalid backup directory (missing manifest): $backup_path"
        return 1
    fi

    # Show backup info
    echo "=== Backup Information ==="
    cat "$backup_path/manifest.txt"
    echo ""

    if [[ "$confirm" != "true" ]]; then
        echo "This will overwrite your current configuration."
        echo "Are you sure you want to continue? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Restore cancelled."
            return 0
        fi
    fi

    # Create automatic backup before restore
    if ([[ -f "$GLOBAL_CONFIG" ]] || [[ -d "$MODULE_CONFIG_DIR" ]]) && declare -f auto_backup >/dev/null 2>&1; then
        auto_backup
    fi

    # Create backup of current config before restore
    local current_backup
    current_backup=$(mktemp -d)
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        cp "$GLOBAL_CONFIG" "$current_backup/"
    fi
    if [[ -d "$MODULE_CONFIG_DIR" ]]; then
        cp -r "$MODULE_CONFIG_DIR" "$current_backup/"
    fi

    # Restore global config
    if [[ -f "$backup_path/global_config.yaml" ]]; then
        cp "$backup_path/global_config.yaml" "$GLOBAL_CONFIG"
        chmod 600 "$GLOBAL_CONFIG"
        echo "Restored global configuration"
    fi

    # Restore module configs
    if [[ -d "$backup_path/modules" ]]; then
        mkdir -p "$MODULE_CONFIG_DIR"
        while IFS= read -r -d '' file; do
            local module_name
            module_name=$(basename "$file")
            cp "$file" "$MODULE_CONFIG_DIR/$module_name"
            chmod 600 "$MODULE_CONFIG_DIR/$module_name"
        done < <(find "$backup_path/modules" -name "*.yaml" -type f -print0 2>/dev/null)
        echo "Restored module configurations"
    fi

    # Clean up temporary backup
    rm -rf "$current_backup"

    echo "Configuration restore completed successfully"
}

# List available backups
list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        echo "No backup directory found: $BACKUP_DIR"
        return 1
    fi

    local found_backups=0
    echo "Available backups:"
    echo "=================="

    while IFS= read -r -d '' backup; do
        if [[ -f "$backup/manifest.txt" ]]; then
            local backup_name
            backup_name=$(basename "$backup")
            local created_date
            created_date=$(grep "^Created:" "$backup/manifest.txt" | sed 's/Created: //')

            printf "%-30s | %s\n" "$backup_name" "$created_date"
            ((found_backups++))
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

    if [[ $found_backups -eq 0 ]]; then
        echo "No backups found"
    else
        echo ""
        echo "Total backups: $found_backups"
    fi
}

# Delete backup
delete_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"

    if [[ ! -d "$backup_path" ]]; then
        echo "Error: Backup not found: $backup_name"
        return 1
    fi

    if [[ ! -f "$backup_path/manifest.txt" ]]; then
        echo "Error: Invalid backup directory: $backup_name"
        return 1
    fi

    echo "Deleting backup: $backup_name"
    echo "This action cannot be undone."
    echo "Are you sure? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Delete cancelled."
        return 0
    fi

    rm -rf "$backup_path"
    echo "Backup deleted: $backup_name"
}

# Validate backup
validate_backup() {
    local backup_path="$1"

    if [[ ! -d "$backup_path" ]]; then
        echo "Error: Backup directory not found: $backup_path"
        return 1
    fi

    if [[ ! -f "$backup_path/manifest.txt" ]]; then
        echo "Error: Invalid backup (missing manifest): $backup_path"
        return 1
    fi

    echo "=== Backup Validation ==="
    cat "$backup_path/manifest.txt"
    echo ""

    local issues_found=0

    # Check global config
    if [[ -f "$backup_path/global_config.yaml" ]]; then
        if command -v yamllint >/dev/null 2>&1; then
            if yamllint "$backup_path/global_config.yaml" >/dev/null 2>&1; then
                echo "✓ Global config: Valid YAML"
            else
                echo "✗ Global config: Invalid YAML"
                ((issues_found++))
            fi
        else
            echo "? Global config: YAML validation skipped (yamllint not available)"
        fi
    else
        echo "? Global config: Not included in backup"
    fi

    # Check module configs
    if [[ -d "$backup_path/modules" ]]; then
        local module_count=0
        local valid_modules=0

        while IFS= read -r -d '' file; do
            ((module_count++))
            if command -v yamllint >/dev/null 2>&1; then
                if yamllint "$file" >/dev/null 2>&1; then
                    ((valid_modules++))
                else
                    local module_name
                    module_name=$(basename "$file")
                    echo "✗ Module config: Invalid YAML - $module_name"
                    ((issues_found++))
                fi
            fi
        done < <(find "$backup_path/modules" -name "*.yaml" -type f -print0 2>/dev/null)

        if [[ $module_count -gt 0 ]]; then
            echo "✓ Module configs: $valid_modules/$module_count valid"
        fi
    else
        echo "? Module configs: Not included in backup"
    fi

    if [[ $issues_found -eq 0 ]]; then
        echo ""
        echo "✓ Backup validation passed"
        return 0
    else
        echo ""
        echo "✗ Backup validation failed with $issues_found issue(s)"
        return 1
    fi
}

# Auto-backup before changes
auto_backup() {
    local backup_name="auto_backup_$(date +"%Y%m%d_%H%M%S")"
    backup_config "$backup_name"

    # Keep only last 5 auto-backups
    local auto_backups=()
    while IFS= read -r -d '' backup; do
        if [[ -f "$backup/manifest.txt" ]] && [[ "$(basename "$backup")" =~ ^auto_backup_ ]]; then
            auto_backups+=("$backup")
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -print0 2>/dev/null)

    # Sort by modification time (newest first) and keep only 5
    if [[ ${#auto_backups[@]} -gt 5 ]]; then
        local sorted_backups
        mapfile -t sorted_backups < <(printf '%s\n' "${auto_backups[@]}" | xargs -I {} stat -c "%Y %n" {} | sort -nr | cut -d' ' -f2-)

        for ((i=5; i<${#sorted_backups[@]}; i++)); do
            local old_backup="${sorted_backups[$i]}"
            echo "Removing old auto-backup: $(basename "$old_backup")"
            rm -rf "$old_backup"
        done
    fi
}