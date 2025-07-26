#!/bin/bash
# state.sh - Simple, reliable state management for upkep

STATE_FILE="$HOME/.upkep_state"
STATE_DIR="$(dirname "$STATE_FILE")"

# Initialize state system
init_state() {
    # Create directory if needed
    [[ ! -d "$STATE_DIR" ]] && mkdir -p "$STATE_DIR"

    # Create initial state file if it doesn't exist
    if [[ ! -f "$STATE_FILE" ]]; then
        create_initial_state
    fi
}

# Create initial state file
create_initial_state() {
    cat > "$STATE_FILE" << 'EOF'
UPDATE_LAST_RUN=0
CLEANUP_LAST_RUN=0
SCRIPT_LAST_RUN=0
UPDATE_DURATION=0
CLEANUP_DURATION=0
UPDATE_STATUS=never
CLEANUP_STATUS=never
SNAP_STATUS=never
FLATPAK_STATUS=never
EOF
}

# Load state from file with validation
load_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        init_state
        return
    fi

    # Basic validation - check if file is readable and has expected format
    if ! validate_state_file; then
        echo "Warning: State file corrupted, recovering..."
        backup_corrupted_state
        create_initial_state
    fi

    # Source the state file
    source "$STATE_FILE"
}

# Validate state file format
validate_state_file() {
    # Check if file is readable
    [[ -r "$STATE_FILE" ]] || return 1

    # Check for required variables (basic validation)
    grep -q "UPDATE_LAST_RUN=" "$STATE_FILE" && \
    grep -q "CLEANUP_LAST_RUN=" "$STATE_FILE" && \
    grep -q "SCRIPT_LAST_RUN=" "$STATE_FILE"
}

# Atomic save using temp file + move
save_state() {
    local temp_file="${STATE_FILE}.tmp.$$"

    # Write to temp file
    cat > "$temp_file" << EOF
UPDATE_LAST_RUN=${UPDATE_LAST_RUN:-0}
CLEANUP_LAST_RUN=${CLEANUP_LAST_RUN:-0}
SCRIPT_LAST_RUN=$(date +%s)
UPDATE_DURATION=${UPDATE_DURATION:-0}
CLEANUP_DURATION=${CLEANUP_DURATION:-0}
UPDATE_STATUS=${UPDATE_STATUS:-never}
CLEANUP_STATUS=${CLEANUP_STATUS:-never}
SNAP_STATUS=${SNAP_STATUS:-never}
FLATPAK_STATUS=${FLATPAK_STATUS:-never}
EOF

    # Atomic move
    if mv "$temp_file" "$STATE_FILE"; then
        return 0
    else
        # Cleanup on failure
        [[ -f "$temp_file" ]] && rm -f "$temp_file"
        return 1
    fi
}

# Update module state with duration tracking
update_module_state() {
    local module_name="$1"
    local status="$2"
    local message="$3"  # unused in simple version
    local duration="${4:-0}"

    case "$module_name" in
        "apt_update")
            UPDATE_LAST_RUN=$(date +%s)
            UPDATE_DURATION="$duration"
            UPDATE_STATUS="$status"
            ;;
        "cleanup")
            CLEANUP_LAST_RUN=$(date +%s)
            CLEANUP_DURATION="$duration"
            CLEANUP_STATUS="$status"
            ;;
        "snap_update")
            SNAP_STATUS="$status"
            ;;
        "flatpak_update")
            FLATPAK_STATUS="$status"
            ;;
    esac
}

# Backward compatibility functions
update_apt_state() {
    UPDATE_LAST_RUN=$(date +%s)
    UPDATE_STATUS="success"
}

update_cleanup_state() {
    CLEANUP_LAST_RUN=$(date +%s)
    CLEANUP_STATUS="success"
}

# Show current status
show_current_status() {
    load_state
    local now=$(date +%s)
    local days_since_update=$(( (now - UPDATE_LAST_RUN) / 86400 ))
    local days_since_cleanup=$(( (now - CLEANUP_LAST_RUN) / 86400 ))
    local days_since_script=$(( (now - SCRIPT_LAST_RUN) / 86400 ))

    draw_box "Last update : $days_since_update day(s) ago" "CURRENT STATUS" "$BLUE"
    draw_box "Last cleanup: $days_since_cleanup day(s) ago" "" "$BLUE"
    draw_box "Last script run: $days_since_script day(s) ago" "" "$BLUE"
}

# Backup corrupted state file
backup_corrupted_state() {
    if [[ -f "$STATE_FILE" ]]; then
        local backup_file="${STATE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$STATE_FILE" "$backup_file" 2>/dev/null
        echo "Backed up corrupted state to: $backup_file"
    fi
}