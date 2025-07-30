#!/bin/bash
# upKep Layout Builder - Progress Indicators
# Provides spinner and progress bar components for Layout Builder boxes
# Based on layout_builder_spec.md v1.2 §8

# Source required components
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)/scripts/core"
fi
source "${SCRIPT_DIR}/palette.sh"

# Progress indicator state
declare -g SPINNER_PID=""
declare -g PROGRESS_PID=""
declare -g SPINNER_ACTIVE=false
declare -g PROGRESS_ACTIVE=false

# Spinner frames
SPINNER_FRAMES_DEFAULT=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
SPINNER_FRAMES_CB=("~" "~" "~" "~" "~" "~" "~" "~" "~" "~")
SPINNER_FRAMES_ASCII=("|" "/" "-" "\\" "|" "/" "-" "\\" "|" "/")

# Progress bar characters
PROGRESS_FILLED="█"
PROGRESS_EMPTY="░"
PROGRESS_FILLED_ASCII="#"
PROGRESS_EMPTY_ASCII="."

# Get spinner frames based on mode
get_spinner_frames() {
    if [[ "${UPKEP_COLORBLIND:-0}" == "1" ]]; then
        echo "${SPINNER_FRAMES_CB[@]}"
    elif [[ "${UPKEP_ASCII:-0}" == "1" ]] || [[ "$LC_ALL" != *"UTF-8"* ]]; then
        echo "${SPINNER_FRAMES_ASCII[@]}"
    else
        echo "${SPINNER_FRAMES_DEFAULT[@]}"
    fi
}

# Get progress bar characters based on mode
get_progress_chars() {
    if [[ "${UPKEP_ASCII:-0}" == "1" ]] || [[ "$LC_ALL" != *"UTF-8"* ]]; then
        echo "$PROGRESS_FILLED_ASCII" "$PROGRESS_EMPTY_ASCII"
    else
        echo "$PROGRESS_FILLED" "$PROGRESS_EMPTY"
    fi
}

# Start a spinner with optional message
start_spinner() {
    local message="${1:-Processing...}"
    local style="${2:-info}"
    
    # Don't start spinner in quiet mode or non-TTY
    if [[ "${UPKEP_QUIET:-0}" == "1" ]] || [[ ! -t 1 ]]; then
        echo "$message..."
        return
    fi
    
    # Hide cursor
    echo -en "\033[?25l"
    
    # Get spinner frames
    local frames
    readarray -t frames < <(get_spinner_frames)
    local frame_count=${#frames[@]}
    local current_frame=0
    
    # Get color for style
    local color_code
    color_code=$(get_color "$style")
    local reset_code="\033[0m"
    
    # Start spinner in background
    (
        while [[ "$SPINNER_ACTIVE" == "true" ]]; do
            local frame="${frames[$current_frame]}"
            echo -en "\r${color_code}${frame}${reset_code} $message"
            sleep 0.1  # 100ms cadence
            current_frame=$(( (current_frame + 1) % frame_count ))
        done
    ) &
    
    SPINNER_PID=$!
    SPINNER_ACTIVE=true
}

# Stop the spinner
stop_spinner() {
    if [[ "$SPINNER_ACTIVE" == "true" ]]; then
        SPINNER_ACTIVE=false
        if [[ -n "$SPINNER_PID" ]]; then
            kill "$SPINNER_PID" 2>/dev/null || true
            wait "$SPINNER_PID" 2>/dev/null || true
        fi
        echo -en "\r\033[K"  # Clear line
        echo -en "\033[?25h"  # Show cursor
        SPINNER_PID=""
    fi
}

# Create a progress bar row for Layout Builder
create_progress_bar_row() {
    local progress="${1:-0}"  # 0-100
    local total_cells="${2:-50}"
    local style="${3:-info}"
    
    # Clamp progress to 0-100
    if (( progress < 0 )); then
        progress=0
    elif (( progress > 100 )); then
        progress=100
    fi
    
    # Calculate filled cells
    local filled_cells=$(( (progress * total_cells) / 100 ))
    local empty_cells=$(( total_cells - filled_cells ))
    
    # Get progress characters
    local filled_char empty_char
    read -r filled_char empty_char < <(get_progress_chars)
    
    # Get color for style
    local color_code
    color_code=$(get_color "$style")
    local reset_code="\033[0m"
    
    # Build progress bar
    local progress_bar=""
    for ((i=0; i<filled_cells; i++)); do
        progress_bar="${progress_bar}${filled_char}"
    done
    for ((i=0; i<empty_cells; i++)); do
        progress_bar="${progress_bar}${empty_char}"
    done
    
    # Return as Layout Builder row
    local row_id
    row_id=$(row_new)
    row_add_cell "$row_id" "$(make_color "$style")"
    row_add_cell "$row_id" "$(make_text "$progress_bar")"
    row_add_cell "$row_id" "$(make_text " $progress%")"
    row_add_cell "$row_id" "$(make_color reset)"
    
    echo "$row_id"
}

# Create a spinner row for Layout Builder
create_spinner_row() {
    local message="${1:-Processing...}"
    local style="${2:-info}"
    
    # Get current spinner frame
    local frames
    readarray -t frames < <(get_spinner_frames)
    local frame_count=${#frames[@]}
    local current_frame=$(( (SPINNER_FRAME_COUNT % frame_count) ))
    local frame="${frames[$current_frame]}"
    
    # Increment frame counter
    SPINNER_FRAME_COUNT=$(( (SPINNER_FRAME_COUNT + 1) % frame_count ))
    
    # Return as Layout Builder row
    local row_id
    row_id=$(row_new)
    row_add_cell "$row_id" "$(make_emoji running)"
    row_add_cell "$row_id" "$(make_text "$message")"
    
    echo "$row_id"
}

# Animated progress bar for Layout Builder
start_progress_bar() {
    local title="${1:-Progress}"
    local style="${2:-info}"
    local total_cells="${3:-50}"
    local update_interval="${4:-0.1}"
    
    # Don't animate in quiet mode or non-TTY
    if [[ "${UPKEP_QUIET:-0}" == "1" ]] || [[ ! -t 1 ]]; then
        echo "$title: 0%"
        return
    fi
    
    # Create progress box
    local box_id
    box_id=$(box_new 80 "$title" "$style")
    
    # Start progress animation in background
    (
        local progress=0
        while [[ "$PROGRESS_ACTIVE" == "true" ]] && (( progress <= 100 )); do
            # Clear previous progress row
            if [[ -n "$PROGRESS_ROW_ID" ]]; then
                # Remove last row (simplified - in real implementation would need row removal)
                :
            fi
            
            # Create new progress row
            local progress_row_id
            progress_row_id=$(create_progress_bar_row "$progress" "$total_cells" "$style")
            box_add_row "$box_id" "$progress_row_id"
            
            # Render box
            box_render "$box_id"
            
            # Update progress
            progress=$(( progress + 2 ))
            sleep "$update_interval"
        done
    ) &
    
    PROGRESS_PID=$!
    PROGRESS_ACTIVE=true
    echo "$box_id"
}

# Stop progress bar
stop_progress_bar() {
    if [[ "$PROGRESS_ACTIVE" == "true" ]]; then
        PROGRESS_ACTIVE=false
        if [[ -n "$PROGRESS_PID" ]]; then
            kill "$PROGRESS_PID" 2>/dev/null || true
            wait "$PROGRESS_PID" 2>/dev/null || true
        fi
        PROGRESS_PID=""
    fi
}

# Create a simple progress indicator box
create_progress_box() {
    local title="${1:-Progress}"
    local message="${2:-Processing...}"
    local style="${3:-info}"
    local progress="${4:-0}"
    local total_cells="${5:-50}"
    
    # Create box
    local box_id
    box_id=$(box_new 80 "$title" "$style")
    
    # Add message row
    local message_row_id
    message_row_id=$(row_new)
    row_add_cell "$message_row_id" "$(make_emoji running)"
    row_add_cell "$message_row_id" "$(make_text "$message")"
    box_add_row "$box_id" "$message_row_id"
    
    # Add progress bar row
    local progress_row_id
    progress_row_id=$(create_progress_bar_row "$progress" "$total_cells" "$style")
    box_add_row "$box_id" "$progress_row_id"
    
    # Render box
    box_render "$box_id"
}

# Cleanup function for progress indicators
cleanup_progress_indicators() {
    stop_spinner
    stop_progress_bar
}

# Trap cleanup on script exit
trap cleanup_progress_indicators EXIT

# Functions are available when script is sourced
# No export needed for sourced scripts 