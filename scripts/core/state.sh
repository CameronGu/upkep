#!/bin/bash

# upKep Enhanced State Management
# Handles state persistence, reflection, and recovery

# State file location
STATE_FILE="$HOME/.upkep/state.json"
STATE_DIR="$HOME/.upkep"

# Initialize state system
init_state() {
    mkdir -p "$STATE_DIR"

    if [[ ! -f "$STATE_FILE" ]]; then
        create_initial_state
    fi
}

# Create initial state file
create_initial_state() {
    cat > "$STATE_FILE" << 'EOF'
{
  "version": "2.0.0",
  "last_updated": "",
  "modules": {},
  "categories": {
    "package_managers": {
      "description": "Package manager updates and maintenance",
      "modules": [],
      "common_patterns": ["update_repos", "upgrade_packages", "handle_errors"]
    },
    "system_cleanup": {
      "description": "System cleanup and maintenance",
      "modules": [],
      "common_patterns": ["remove_files", "clean_cache", "log_operations"]
    }
  },
  "patterns": {
    "error_handling": "if [[ $? -eq 0 ]]; then STATUS='success'; else STATUS='failed'; fi",
    "state_update": "update_<module>_state",
    "status_vars": "<MODULE>_STATUS, <MODULE>_MESSAGE, <MODULE>_ERROR",
    "progress_indicator": "spinner $! 'Operation description'"
  },
  "global": {
    "script_last_run": "",
    "total_execution_time": 0,
    "modules_executed": 0,
    "modules_skipped": 0,
    "modules_failed": 0
  }
}
EOF
    echo "Created initial state file: $STATE_FILE"
}

# Load state from file
load_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        init_state
    fi

    # Validate JSON syntax
    if ! jq empty "$STATE_FILE" 2>/dev/null; then
        echo "Warning: Invalid JSON in state file, attempting recovery"
        backup_corrupted_state
        create_initial_state
    fi
}

# Save state to file
save_state() {
    # Update last_updated timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update the timestamp in the state file
    if command -v jq >/dev/null 2>&1; then
        jq ".last_updated = \"$timestamp\"" "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        # Fallback without jq
        sed -i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/" "$STATE_FILE"
    fi
}

# Update module state
update_module_state() {
    local module_name="$1"
    local status="$2"
    local message="${3:-}"
    local duration="${4:-0}"

    if [[ ! -f "$STATE_FILE" ]]; then
        init_state
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if command -v jq >/dev/null 2>&1; then
        # Use jq for proper JSON manipulation
        jq --arg name "$module_name" \
           --arg status "$status" \
           --arg message "$message" \
           --arg duration "$duration" \
           --arg timestamp "$timestamp" \
           '.modules[$name] = {
             "name": $name,
             "last_run": $timestamp,
             "status": $status,
             "duration": ($duration | tonumber),
             "message": $message
           }' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        # Fallback without jq - simple text replacement
        local module_entry="\"$module_name\": {\"name\": \"$module_name\", \"last_run\": \"$timestamp\", \"status\": \"$status\", \"duration\": $duration, \"message\": \"$message\"}"

        # Check if module already exists in state
        if grep -q "\"$module_name\":" "$STATE_FILE"; then
            # Replace existing entry
            sed -i "/\"$module_name\": {/,/}/c\\  $module_entry" "$STATE_FILE"
        else
            # Add new entry before the closing brace of modules object
            sed -i 's/^  }$/  '"$module_entry"',\n  }/' "$STATE_FILE"
        fi
    fi
}

# Get module state
get_module_state() {
    local module_name="$1"

    if [[ ! -f "$STATE_FILE" ]]; then
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        jq -r ".modules.$module_name // empty" "$STATE_FILE"
    else
        # Fallback without jq - simple grep extraction
        local module_section=$(sed -n "/\"$module_name\": {/,/}/p" "$STATE_FILE")
        if [[ -n "$module_section" ]]; then
            echo "$module_section"
        fi
    fi
}

# Update state reflection with module information
update_state_reflection() {
    if [[ ! -f "$STATE_FILE" ]]; then
        init_state
    fi

    # This function will be called after modules are loaded
    # to update the state file with current module information
    echo "Updating state reflection..."

    # Update module information in state
    for module_name in "${!MODULE_REGISTRY[@]}"; do
        local module_file="${MODULE_REGISTRY[$module_name]}"
        local description=$(get_module_description "$module_name")
        local category="${MODULE_CATEGORIES[$module_name]}"
        local functions=$(get_module_functions "$module_name")

        update_module_in_state "$module_name" "$description" "$category" "$functions"
    done

    # Identify and update common patterns
    identify_common_patterns

    echo "State reflection updated"
}

# Get module description
get_module_description() {
    local module_name="$1"
    local module_file="${MODULE_REGISTRY[$module_name]}"

    # Try to extract description from module file
    local description=$(grep -i "description:" "$module_file" | head -1 | sed 's/.*description: *//i')
    if [[ -n "$description" ]]; then
        echo "$description"
    else
        echo "Module for $module_name operations"
    fi
}

# Get module functions
get_module_functions() {
    local module_name="$1"
    local module_file="${MODULE_REGISTRY[$module_name]}"

    # Extract function names from module file
    grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$module_file" | sed 's/()//' | tr '\n' ',' | sed 's/,$//'
}

# Update module information in state
update_module_in_state() {
    local module_name="$1"
    local description="$2"
    local category="$3"
    local functions="$4"

    if command -v jq >/dev/null 2>&1; then
        jq --arg name "$module_name" \
           --arg desc "$description" \
           --arg cat "$category" \
           --arg funcs "$functions" \
           '.modules[$name] = (.modules[$name] // {}) + {
             "description": $desc,
             "category": $cat,
             "functions": ($funcs | split(","))
           }' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
}

# Identify common patterns across modules
identify_common_patterns() {
    echo "Identifying common patterns..."

    # This is a simplified pattern identification
    # In a full implementation, this would analyze module code for patterns

    local patterns="{
      \"error_handling\": \"if [[ \\\$? -eq 0 ]]; then STATUS='success'; else STATUS='failed'; fi\",
      \"state_update\": \"update_<module>_state\",
      \"status_vars\": \"<MODULE>_STATUS, <MODULE>_MESSAGE, <MODULE>_ERROR\",
      \"progress_indicator\": \"spinner \\\$! 'Operation description'\"
    }"

    if command -v jq >/dev/null 2>&1; then
        jq --argjson patterns "$patterns" '.patterns = $patterns' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
}

# Update global execution statistics
update_global_stats() {
    local total_time="$1"
    local executed="$2"
    local skipped="$3"
    local failed="$4"

    if command -v jq >/dev/null 2>&1; then
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        jq --arg timestamp "$timestamp" \
           --arg total_time "$total_time" \
           --arg executed "$executed" \
           --arg skipped "$skipped" \
           --arg failed "$failed" \
           '.global = {
             "script_last_run": $timestamp,
             "total_execution_time": ($total_time | tonumber),
             "modules_executed": ($executed | tonumber),
             "modules_skipped": ($skipped | tonumber),
             "modules_failed": ($failed | tonumber)
           }' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi
}

# Backup corrupted state file
backup_corrupted_state() {
    if [[ -f "$STATE_FILE" ]]; then
        local backup_file="${STATE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$STATE_FILE" "$backup_file"
        echo "Backed up corrupted state file to: $backup_file"
    fi
}

# Recover state from backup
recover_state() {
    local backup_file="$1"

    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" "$STATE_FILE"
        echo "Recovered state from backup: $backup_file"
        return 0
    else
        echo "Backup file not found: $backup_file"
        return 1
    fi
}

# Show state information
show_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "State file not found. Run init_state first."
        return 1
    fi

    echo "upKep State Information:"
    echo "========================"

    if command -v jq >/dev/null 2>&1; then
        # Show global statistics
        echo "Global Statistics:"
        jq -r '.global | to_entries[] | "  \(.key): \(.value)"' "$STATE_FILE"
        echo

        # Show module statistics
        echo "Module Statistics:"
        jq -r '.modules | to_entries[] | "  \(.key): \(.value.status) (\(.value.last_run // "never"))"' "$STATE_FILE"
        echo

        # Show categories
        echo "Categories:"
        jq -r '.categories | to_entries[] | "  \(.key): \(.value.description)"' "$STATE_FILE"
    else
        # Fallback without jq
        echo "Global Statistics:"
        grep -A 10 '"global":' "$STATE_FILE" | grep -E '"[^"]*":' | sed 's/^/  /'
        echo

        echo "Module Statistics:"
        grep -A 5 '"modules":' "$STATE_FILE" | grep -E '"[^"]*":' | sed 's/^/  /'
    fi
}

# Clear state for a specific module
clear_module_state() {
    local module_name="$1"

    if command -v jq >/dev/null 2>&1; then
        jq "del(.modules.$module_name)" "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
        echo "Cleared state for module: $module_name"
    else
        # Fallback without jq
        sed -i "/\"$module_name\": {/,/}/d" "$STATE_FILE"
        echo "Cleared state for module: $module_name"
    fi
}

# Clear all state
clear_all_state() {
    if [[ -f "$STATE_FILE" ]]; then
        backup_corrupted_state
        create_initial_state
        echo "Cleared all state information"
    fi
}

# Export state to different formats
export_state() {
    local format="${1:-json}"
    local output_file="${2:-}"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo "State file not found"
        return 1
    fi

    case "$format" in
        "json")
            if [[ -n "$output_file" ]]; then
                cp "$STATE_FILE" "$output_file"
            else
                cat "$STATE_FILE"
            fi
            ;;
        "yaml")
            if command -v jq >/dev/null 2>&1 && command -v yq >/dev/null 2>&1; then
                local yaml_data=$(jq -r . "$STATE_FILE" | yq eval -P -)
                if [[ -n "$output_file" ]]; then
                    echo "$yaml_data" > "$output_file"
                else
                    echo "$yaml_data"
                fi
            else
                echo "yq not found. Install yq for YAML export support."
                return 1
            fi
            ;;
        *)
            echo "Unsupported format: $format"
            echo "Supported formats: json, yaml"
            return 1
            ;;
    esac
}