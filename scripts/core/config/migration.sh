#!/bin/bash
# migration.sh - Configuration migration system for upKep

# Migration system version
MIGRATION_VERSION="1.0.0"

# Migration history file
MIGRATION_HISTORY="$HOME/.upkep/migration_history.json"

# Get current project version from Makefile
get_project_version() {
    local makefile_path="$SCRIPT_DIR/../../Makefile"
    local makefile_version

    if [[ -f "$makefile_path" ]]; then
        makefile_version=$(grep "^VERSION = " "$makefile_path" | cut -d' ' -f3 2>/dev/null)
        echo "${makefile_version:-2.0.0}"
    else
        echo "2.0.0"
    fi
}

# Get config version from config file
get_config_version() {
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        if command -v yq >/dev/null 2>&1; then
            local version
            version=$(yq eval '.version' "$GLOBAL_CONFIG" 2>/dev/null)
            if [[ "$version" != "null" && -n "$version" ]]; then
                echo "$version"
                return 0
            fi
        else
            # Fallback to grep
            local version
            version=$(grep "^version:" "$GLOBAL_CONFIG" | sed 's/version:[[:space:]]*//')
            if [[ -n "$version" ]]; then
                echo "$version"
                return 0
            fi
        fi
    fi
    echo "1.0.0"  # Default version for old configs
}

# Set config version in config file
set_config_version() {
    local version="$1"

    if [[ ! -f "$GLOBAL_CONFIG" ]]; then
        init_config
    fi

    if command -v yq >/dev/null 2>&1; then
        yq eval ".version = \"$version\"" -i "$GLOBAL_CONFIG" 2>/dev/null || {
            # Fallback if yq fails
            local temp_file
            temp_file=$(mktemp)

            # Add version at the top of the file
            echo "version: $version" > "$temp_file"
            echo "" >> "$temp_file"
            cat "$GLOBAL_CONFIG" >> "$temp_file"
            mv "$temp_file" "$GLOBAL_CONFIG"
        }
    else
        # Fallback to sed
        if ! grep -q "^version:" "$GLOBAL_CONFIG"; then
            local temp_file
            temp_file=$(mktemp)
            echo "version: $version" > "$temp_file"
            echo "" >> "$temp_file"
            cat "$GLOBAL_CONFIG" >> "$temp_file"
            mv "$temp_file" "$GLOBAL_CONFIG"
        else
            sed -i "s/^version:.*/version: $version/" "$GLOBAL_CONFIG"
        fi
    fi
}

# Initialize migration history
init_migration_history() {
    if [[ ! -f "$MIGRATION_HISTORY" ]]; then
        mkdir -p "$(dirname "$MIGRATION_HISTORY")"
        cat > "$MIGRATION_HISTORY" << EOF
{
  "migrations": [],
  "last_check": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "current_version": "$(get_config_version)"
}
EOF
        chmod 600 "$MIGRATION_HISTORY"
    fi
}

# Record migration in history
record_migration() {
    local from_version="$1"
    local to_version="$2"
    local migration_script="$3"
    local status="$4"
    local details="$5"

    init_migration_history

    if command -v jq >/dev/null 2>&1; then
        local temp_file
        temp_file=$(mktemp)

        jq --arg from "$from_version" \
           --arg to "$to_version" \
           --arg script "$migration_script" \
           --arg status "$status" \
           --arg details "$details" \
           --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
           '.migrations += [{
             "from_version": $from,
             "to_version": $to,
             "script": $script,
             "status": $status,
             "details": $details,
             "timestamp": $timestamp
           }] | .last_check = $timestamp | .current_version = $to' \
           "$MIGRATION_HISTORY" > "$temp_file"

        mv "$temp_file" "$MIGRATION_HISTORY"
    else
        # Fallback without jq - append to file
        echo "Migration: $from_version -> $to_version ($status) - $details" >> "$MIGRATION_HISTORY"
    fi
}

# Check if migration is needed
check_migration_needed() {
    local current_version
    current_version=$(get_config_version)
    local project_version
    project_version=$(get_project_version)

    if [[ "$current_version" != "$project_version" ]]; then
        echo "Migration needed: $current_version -> $project_version"
        return 0
    else
        echo "No migration needed. Config version: $current_version"
        return 1
    fi
}

# Get available migration scripts
get_available_migrations() {
    local current_version="$1"
    local target_version="$2"
    local migrations_dir="$SCRIPT_DIR/config/migrations"

    if [[ ! -d "$migrations_dir" ]]; then
        return 1
    fi

    # Find migration scripts that can handle this version upgrade
    while IFS= read -r -d '' script; do
        local script_name
        script_name=$(basename "$script" .sh)

        # Parse version range from script name (e.g., "1.0.0_to_2.0.0.sh")
        if [[ "$script_name" =~ ^([0-9]+\.[0-9]+\.[0-9]+)_to_([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
            local from_version="${BASH_REMATCH[1]}"
            local to_version="${BASH_REMATCH[2]}"

            if [[ "$from_version" == "$current_version" && "$to_version" == "$target_version" ]]; then
                echo "$script"
                return 0
            fi
        fi
    done < <(find "$migrations_dir" -name "*.sh" -type f -print0 2>/dev/null)

    return 1
}

# Run migration script
run_migration_script() {
    local script_path="$1"
    local from_version="$2"
    local to_version="$3"

    if [[ ! -f "$script_path" ]]; then
        echo "Error: Migration script not found: $script_path"
        return 1
    fi

    if [[ ! -x "$script_path" ]]; then
        chmod +x "$script_path"
    fi

    echo "Running migration script: $(basename "$script_path")"
    echo "Migrating from version $from_version to $to_version..."

    # Create backup before migration
    backup_config

    # Run the migration script
    if "$script_path" "$from_version" "$to_version"; then
        # Update config version
        set_config_version "$to_version"

        # Record successful migration
        record_migration "$from_version" "$to_version" "$(basename "$script_path")" "success" "Migration completed successfully"

        return 0
    else
        # Record failed migration
        record_migration "$from_version" "$to_version" "$(basename "$script_path")" "failed" "Migration script failed"

        echo "Migration failed! Check logs for details."
        return 1
    fi
}

# Perform automatic migration
perform_migration() {
    local current_version
    current_version=$(get_config_version)
    local project_version
    project_version=$(get_project_version)

    echo "=== upKep Configuration Migration ==="
    echo "Current config version: $current_version"
    echo "Project version: $project_version"
    echo ""

    if [[ "$current_version" == "$project_version" ]]; then
        echo "No migration needed. Config is up to date."
        return 0
    fi

    # Debug: Check migrations directory
    local migrations_dir="$SCRIPT_DIR/config/migrations"
    echo "Debug: Looking for migrations in: $migrations_dir"

    if [[ ! -d "$migrations_dir" ]]; then
        echo "Error: Migrations directory not found: $migrations_dir"
        return 1
    fi

    # Find migration script
    local migration_script
    migration_script=$(get_available_migrations "$current_version" "$project_version")

    if [[ -z "$migration_script" ]]; then
        echo "Error: No migration script found for $current_version -> $project_version"
        echo "Available migrations:"
        if [[ -d "$migrations_dir" ]]; then
            while IFS= read -r -d '' script; do
                echo "  - $(basename "$script")"
            done < <(find "$migrations_dir" -name "*.sh" -type f -print0 2>/dev/null)
        fi
        echo ""
        echo "Migration failed. Please ensure a migration script exists for $current_version -> $project_version"
        return 1
    fi

    # Confirm migration
    echo "Migration script found: $(basename "$migration_script")"
    echo -n "Proceed with migration? (y/N): "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        if run_migration_script "$migration_script" "$current_version" "$project_version"; then
            echo "Migration completed successfully!"
            return 0
        else
            echo "Migration failed!"
            return 1
        fi
    else
        echo "Migration cancelled."
        return 0
    fi
}

# Show migration history
show_migration_history() {
    if [[ ! -f "$MIGRATION_HISTORY" ]]; then
        echo "No migration history found."
        return 0
    fi

    echo "=== Migration History ==="

    if command -v jq >/dev/null 2>&1; then
        jq -r '.migrations[] | "\(.timestamp) | \(.from_version) -> \(.to_version) | \(.status) | \(.script)"' "$MIGRATION_HISTORY" 2>/dev/null || {
            echo "Error parsing migration history JSON"
            cat "$MIGRATION_HISTORY"
        }
    else
        # Fallback - show raw file
        cat "$MIGRATION_HISTORY"
    fi

    echo ""
    echo "Last check: $(jq -r '.last_check' "$MIGRATION_HISTORY" 2>/dev/null || echo "Unknown")"
    echo "Current version: $(jq -r '.current_version' "$MIGRATION_HISTORY" 2>/dev/null || echo "Unknown")"
}

# Create migration script template
create_migration_template() {
    local from_version="$1"
    local to_version="$2"
    local migrations_dir="$SCRIPT_DIR/migrations"

    mkdir -p "$migrations_dir"

    local script_name="${from_version}_to_${to_version}.sh"
    local script_path="$migrations_dir/$script_name"

    if [[ -f "$script_path" ]]; then
        echo "Migration script already exists: $script_path"
        return 1
    fi

    cat > "$script_path" << EOF
#!/bin/bash
# Migration script: $from_version -> $to_version
# Generated on $(date)

# Migration script for upgrading configuration from version $from_version to $to_version
# This script should handle all necessary changes to the configuration structure

# Source the main config functions
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\$SCRIPT_DIR/../config.sh"

# Migration function
migrate_${from_version//./_}_to_${to_version//./_}() {
    local from_version="\$1"
    local to_version="\$2"

    echo "Starting migration from \$from_version to \$to_version..."

    # TODO: Implement migration logic here
    # Examples of common migration tasks:

    # 1. Add new configuration keys
    # if ! get_global_config "new_setting" "" >/dev/null 2>&1; then
    #     set_global_config "new_setting" "default_value"
    # fi

    # 2. Rename configuration keys
    # local old_value
    # old_value=\$(get_global_config "old_key" "")
    # if [[ -n "\$old_value" ]]; then
    #     set_global_config "new_key" "\$old_value"
    #     # Remove old key if needed
    # fi

    # 3. Update configuration structure
    # if command -v yq >/dev/null 2>&1; then
    #     yq eval '.new_section = {}' -i "\$GLOBAL_CONFIG"
    # fi

    # 4. Validate migrated configuration
    # if ! validate_config_schema; then
    #     echo "Error: Configuration validation failed after migration"
    #     return 1
    # fi

    echo "Migration completed successfully!"
    return 0
}

# Main execution
if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
    migrate_${from_version//./_}_to_${to_version//./_} "\$@"
fi
EOF

    chmod +x "$script_path"
    echo "Migration template created: $script_path"
    echo "Please edit the script to implement the actual migration logic."
}

# Export functions
export -f get_project_version
export -f get_config_version
export -f set_config_version
export -f init_migration_history
export -f record_migration
export -f check_migration_needed
export -f get_available_migrations
export -f run_migration_script
export -f perform_migration
export -f show_migration_history
export -f create_migration_template