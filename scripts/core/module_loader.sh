#!/bin/bash

# upKep Module Loader
# Handles dynamic module discovery, loading, and registry management

# Module discovery paths
CORE_MODULES_DIR="$(dirname "$0")/../modules/core"
USER_MODULES_DIR="$HOME/.upkep/modules"

# Module registry (in-memory)
declare -A MODULE_REGISTRY
declare -A MODULE_METADATA
declare -A MODULE_CATEGORIES

# Initialize module system
init_module_system() {
    # Create user modules directory if it doesn't exist
    mkdir -p "$USER_MODULES_DIR"

    # Clear registry
    MODULE_REGISTRY=()
    MODULE_METADATA=()
    MODULE_CATEGORIES=()

    # Discover and load modules
    discover_modules
}

# Discover modules from all paths
discover_modules() {
    echo "Discovering modules..."

    # Load core modules
    if [[ -d "$CORE_MODULES_DIR" ]]; then
        for module_file in "$CORE_MODULES_DIR"/*.sh; do
            if [[ -f "$module_file" ]]; then
                load_module "$module_file" "core"
            fi
        done
    fi

    # Load user modules
    if [[ -d "$USER_MODULES_DIR" ]]; then
        for module_file in "$USER_MODULES_DIR"/*.sh; do
            if [[ -f "$module_file" ]]; then
                load_module "$module_file" "user"
            fi
        done
    fi

    echo "Discovered ${#MODULE_REGISTRY[@]} modules"
}

# Load a single module
load_module() {
    local module_file="$1"
    local module_type="$2"
    local module_name=$(basename "$module_file" .sh)

    # Check if module is already loaded
    if [[ -n "${MODULE_REGISTRY[$module_name]}" ]]; then
        echo "Module $module_name already loaded, skipping"
        return 0
    fi

    # Validate module structure
    if ! validate_module_structure "$module_file"; then
        echo "Invalid module structure: $module_file"
        return 1
    fi

    # Source the module
    if source "$module_file"; then
        # Register module
        MODULE_REGISTRY["$module_name"]="$module_file"
        MODULE_METADATA["$module_name"]="$module_type"

        # Determine category
        local category=$(get_module_category "$module_name")
        MODULE_CATEGORIES["$module_name"]="$category"

        echo "Loaded module: $module_name ($module_type, $category)"
        return 0
    else
        echo "Failed to load module: $module_file"
        return 1
    fi
}

# Validate module structure
validate_module_structure() {
    local module_file="$1"
    local module_name=$(basename "$module_file" .sh)

    # Check if required function exists
    if ! grep -q "run_${module_name}()" "$module_file"; then
        echo "Module $module_name missing required function: run_${module_name}()"
        return 1
    fi

    # Check for basic syntax errors
    if ! bash -n "$module_file" 2>/dev/null; then
        echo "Module $module_name has syntax errors"
        return 1
    fi

    return 0
}

# Get module category
get_module_category() {
    local module_name="$1"

    # Determine category based on module name or content
    case "$module_name" in
        *apt*|*snap*|*flatpak*|*package*)
            echo "package_managers"
            ;;
        *cleanup*|*clean*|*remove*)
            echo "system_cleanup"
            ;;
        *security*|*audit*)
            echo "security"
            ;;
        *backup*|*restore*)
            echo "backup"
            ;;
        *monitor*|*check*)
            echo "monitoring"
            ;;
        *)
            echo "system_maintenance"
            ;;
    esac
}

# Get module information
get_module_info() {
    local module_name="$1"

    if [[ -z "${MODULE_REGISTRY[$module_name]}" ]]; then
        echo "Module not found: $module_name"
        return 1
    fi

    local module_file="${MODULE_REGISTRY[$module_name]}"
    local module_type="${MODULE_METADATA[$module_name]}"
    local category="${MODULE_CATEGORIES[$module_name]}"

    echo "Module: $module_name"
    echo "  File: $module_file"
    echo "  Type: $module_type"
    echo "  Category: $category"
    echo "  Functions:"

    # List available functions
    local functions=$(grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$module_file" | sed 's/()//')
    for func in $functions; do
        echo "    - $func"
    done
}

# List modules by category
list_modules_by_category() {
    local category="${1:-}"

    if [[ -z "$category" ]]; then
        echo "Available categories:"
        for cat in $(printf '%s\n' "${MODULE_CATEGORIES[@]}" | sort -u); do
            local count=0
            for module in "${!MODULE_CATEGORIES[@]}"; do
                if [[ "${MODULE_CATEGORIES[$module]}" == "$cat" ]]; then
                    ((count++))
                fi
            done
            echo "  $cat: $count modules"
        done
    else
        echo "Modules in category '$category':"
        for module in "${!MODULE_CATEGORIES[@]}"; do
            if [[ "${MODULE_CATEGORIES[$module]}" == "$category" ]]; then
                local module_type="${MODULE_METADATA[$module]}"
                echo "  - $module ($module_type)"
            fi
        done
    fi
}

# List all modules
list_all_modules() {
    echo "All loaded modules:"
    for module in "${!MODULE_REGISTRY[@]}"; do
        local module_type="${MODULE_METADATA[$module]}"
        local category="${MODULE_CATEGORIES[$module]}"
        echo "  - $module ($module_type, $category)"
    done
}

# Check if module exists
module_exists() {
    local module_name="$1"
    [[ -n "${MODULE_REGISTRY[$module_name]}" ]]
}

# Get module file path
get_module_file() {
    local module_name="$1"
    echo "${MODULE_REGISTRY[$module_name]}"
}

# Execute a module
execute_module() {
    local module_name="$1"
    shift
    local args=("$@")

    if ! module_exists "$module_name"; then
        echo "Module not found: $module_name"
        return 1
    fi

    # Check if module is enabled
    local enabled=$(get_module_config "$module_name" "enabled" "true")
    if [[ "$enabled" != "true" ]]; then
        echo "Module $module_name is disabled"
        return 0
    fi

    # Execute the module's run function
    if declare -f "run_${module_name}" >/dev/null; then
        echo "Executing module: $module_name"
        "run_${module_name}" "${args[@]}"
        return $?
    else
        echo "Module $module_name missing run function: run_${module_name}()"
        return 1
    fi
}

# Get module status
get_module_status() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Module not found: $module_name"
        return 1
    fi

    # Check if module has status function
    if declare -f "get_${module_name}_status" >/dev/null; then
        "get_${module_name}_status"
    else
        echo "Module $module_name has no status function"
        return 1
    fi
}

# Validate module environment
validate_module_environment() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Module not found: $module_name"
        return 1
    fi

    # Check if module has validation function
    if declare -f "validate_${module_name}_environment" >/dev/null; then
        "validate_${module_name}_environment"
        return $?
    else
        # Default validation - module exists and can be loaded
        return 0
    fi
}

# Reload a module
reload_module() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Module not found: $module_name"
        return 1
    fi

    local module_file="${MODULE_REGISTRY[$module_name]}"
    local module_type="${MODULE_METADATA[$module_name]}"

    # Remove from registry
    unset "MODULE_REGISTRY[$module_name]"
    unset "MODULE_METADATA[$module_name]"
    unset "MODULE_CATEGORIES[$module_name]"

    # Reload module
    load_module "$module_file" "$module_type"
}

# Unload a module
unload_module() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Module not found: $module_name"
        return 1
    fi

    # Remove from registry
    unset "MODULE_REGISTRY[$module_name]"
    unset "MODULE_METADATA[$module_name]"
    unset "MODULE_CATEGORIES[$module_name]"

    echo "Unloaded module: $module_name"
}

# Get module count
get_module_count() {
    echo "${#MODULE_REGISTRY[@]}"
}

# Get modules by type
get_modules_by_type() {
    local module_type="$1"

    for module in "${!MODULE_METADATA[@]}"; do
        if [[ "${MODULE_METADATA[$module]}" == "$module_type" ]]; then
            echo "$module"
        fi
    done
}