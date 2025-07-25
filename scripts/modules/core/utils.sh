#!/bin/bash
# utils.sh - Enhanced utility functions for box drawing, styling, and visual feedback
# Implements Taskmaster-inspired visual design with terminal-first dark theme

# =============================================================================
# COLOR SYSTEM - Terminal-first dark theme with semantic color palette
# =============================================================================

# Base ANSI escape codes
RESET=$(printf "\e[0m")
BOLD="\e[1m"
DIM="\e[2m"
ITALIC="\e[3m"
UNDERLINE="\e[4m"
BLINK="\e[5m"
REVERSE="\e[7m"
HIDDEN="\e[8m"

# Legacy color support (8-bit)
WHITE="\e[97m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
GRAY="\e[90m"

# Enhanced color palette from DESIGN.md
# Primary colors for terminal-first dark theme
PRIMARY_BG="\e[48;2;26;26;26m"    # #1a1a1a - Deep black background
PRIMARY_FG="\e[38;2;248;248;242m" # #f8f8f2 - High-contrast white text
ACCENT_CYAN="\e[38;2;139;233;253m"   # #8be9fd - Headers, section dividers
ACCENT_MAGENTA="\e[38;2;189;147;249m" # #bd93f9 - Progress, emphasis

# Semantic status colors (colorblind-friendly alternatives)
SUCCESS_GREEN="\e[38;2;80;250;123m"   # #50fa7b - Completed tasks, successful operations
WARNING_YELLOW="\e[38;2;241;250;140m" # #f1fa8c - Skipped tasks, pending actions
ERROR_RED="\e[38;2;255;85;85m"        # #ff5555 - Failed operations, critical issues
INFO_BLUE="\e[38;2;98;114;164m"       # #6272a4 - Informational content, metadata

# Colorblind-friendly alternatives (high contrast)
SUCCESS_GREEN_ALT="\e[38;2;0;215;0m"  # #00d700 - Bright green, distinct from red
WARNING_YELLOW_ALT="\e[38;2;255;215;0m" # #ffd700 - Golden yellow, high contrast
ERROR_RED_ALT="\e[38;2;255;0;0m"      # #ff0000 - Pure red, maximum contrast
INFO_BLUE_ALT="\e[38;2;0;135;255m"    # #0087ff - Bright blue, distinct

# =============================================================================
# COLOR DETECTION AND FALLBACK SYSTEM
# =============================================================================

# Detect terminal color support
detect_color_support() {
    local colors
    if command -v tput >/dev/null 2>&1; then
        colors=$(tput colors 2>/dev/null || echo 8)
    else
        colors=8
    fi

    # Check if terminal supports 24-bit color
    if [[ "$colors" -ge 256 ]] && [[ -n "$TERM" ]]; then
        # Test 24-bit color support
        if [[ "$TERM" =~ (xterm|screen|tmux|rxvt|linux) ]]; then
            echo "24bit"
        else
            echo "256"
        fi
    elif [[ "$colors" -ge 8 ]]; then
        echo "8"
    else
        echo "none"
    fi
}

# Get color code with fallback support
get_color() {
    local color_name="$1"
    local color_support=$(detect_color_support)

    case "$color_support" in
        "24bit")
            case "$color_name" in
                "primary_bg") printf "%b" "$PRIMARY_BG" ;;
                "primary_fg") printf "%b" "$PRIMARY_FG" ;;
                "accent_cyan") printf "%b" "$ACCENT_CYAN" ;;
                "accent_magenta") printf "%b" "$ACCENT_MAGENTA" ;;
                "success") printf "%b" "$SUCCESS_GREEN" ;;
                "warning") printf "%b" "$WARNING_YELLOW" ;;
                "error") printf "%b" "$ERROR_RED" ;;
                "info") printf "%b" "$INFO_BLUE" ;;
                *) printf "%b" "$WHITE" ;;
            esac
            ;;
        "256"|"8")
            case "$color_name" in
                "success") printf "%b" "$GREEN" ;;
                "warning") printf "%b" "$YELLOW" ;;
                "error") printf "%b" "$RED" ;;
                "info") printf "%b" "$BLUE" ;;
                "accent_cyan") printf "%b" "$CYAN" ;;
                "accent_magenta") printf "%b" "$MAGENTA" ;;
                *) printf "%b" "$WHITE" ;;
            esac
            ;;
        *)
            printf "" # No color support
            ;;
    esac
}

# =============================================================================
# ENHANCED UTILITY FUNCTIONS
# =============================================================================

# Get terminal width with fallback
get_terminal_width() {
    local width
    if command -v tput >/dev/null 2>&1; then
        width=$(tput cols 2>/dev/null || echo 80)
    else
        width=80
    fi
    echo "$width"
}

# Dynamic box width based on terminal size
get_box_width() {
    local terminal_width=$(get_terminal_width)
    local min_width=60
    local max_width=120
    local preferred_width=80

    if [[ "$terminal_width" -lt "$min_width" ]]; then
        echo "$min_width"
    elif [[ "$terminal_width" -gt "$max_width" ]]; then
        echo "$max_width"
    else
        echo "$preferred_width"
    fi
}

# Unicode-aware display width calculation
# This function calculates the actual display width of a string, accounting for:
# - Wide characters (emojis, CJK characters) = 2 columns
# - Combining characters = 0 columns
# - Control characters = variable width
get_display_width() {
    local text="$1"
    local width=0
    local i=0

    while [[ $i -lt ${#text} ]]; do
        local char="${text:$i:1}"
        local code=$(printf '%d' "'$char")

        # Check for wide characters (emojis, CJK, etc.)
        if [[ $((code)) -ge $((0x1F600)) && $((code)) -le $((0x1F64F)) ]] || \
           [[ $((code)) -ge $((0x1F300)) && $((code)) -le $((0x1F5FF)) ]] || \
           [[ $((code)) -ge $((0x1F680)) && $((code)) -le $((0x1F6FF)) ]] || \
           [[ $((code)) -ge $((0x1F1E0)) && $((code)) -le $((0x1F1FF)) ]] || \
           [[ $((code)) -ge $((0x2600)) && $((code)) -le $((0x26FF)) ]] || \
           [[ $((code)) -ge $((0x2700)) && $((code)) -le $((0x27BF)) ]] || \
           [[ $((code)) -ge $((0xFE00)) && $((code)) -le $((0xFE0F)) ]] || \
           [[ $((code)) -ge $((0x1F900)) && $((code)) -le $((0x1F9FF)) ]] || \
           [[ $((code)) -ge $((0x1F018)) && $((code)) -le $((0x1F270)) ]] || \
           [[ $((code)) -ge $((0x238C)) && $((code)) -le $((0x2454)) ]] || \
           [[ $((code)) -ge $((0x20D0)) && $((code)) -le $((0x20FF)) ]] || \
           [[ $((code)) -ge $((0x2B00)) && $((code)) -le $((0x2BFF)) ]] || \
           [[ $((code)) -ge $((0x2900)) && $((code)) -le $((0x297F)) ]] || \
           [[ $((code)) -ge $((0x2A00)) && $((code)) -le $((0x2AFF)) ]] || \
           [[ $((code)) -ge $((0x2B00)) && $((code)) -le $((0x2BFF)) ]] || \
           [[ $((code)) -ge $((0x2E80)) && $((code)) -le $((0x2EFF)) ]] || \
           [[ $((code)) -ge $((0x3000)) && $((code)) -le $((0x303F)) ]] || \
           [[ $((code)) -ge $((0x3040)) && $((code)) -le $((0x309F)) ]] || \
           [[ $((code)) -ge $((0x30A0)) && $((code)) -le $((0x30FF)) ]] || \
           [[ $((code)) -ge $((0x3100)) && $((code)) -le $((0x312F)) ]] || \
           [[ $((code)) -ge $((0x3130)) && $((code)) -le $((0x318F)) ]] || \
           [[ $((code)) -ge $((0x3190)) && $((code)) -le $((0x319F)) ]] || \
           [[ $((code)) -ge $((0x31A0)) && $((code)) -le $((0x31BF)) ]] || \
           [[ $((code)) -ge $((0x31C0)) && $((code)) -le $((0x31EF)) ]] || \
           [[ $((code)) -ge $((0x31F0)) && $((code)) -le $((0x31FF)) ]] || \
           [[ $((code)) -ge $((0x3200)) && $((code)) -le $((0x32FF)) ]] || \
           [[ $((code)) -ge $((0x3300)) && $((code)) -le $((0x33FF)) ]] || \
           [[ $((code)) -ge $((0x3400)) && $((code)) -le $((0x4DBF)) ]] || \
           [[ $((code)) -ge $((0x4DC0)) && $((code)) -le $((0x4DFF)) ]] || \
           [[ $((code)) -ge $((0x4E00)) && $((code)) -le $((0x9FFF)) ]] || \
           [[ $((code)) -ge $((0xA000)) && $((code)) -le $((0xA48F)) ]] || \
           [[ $((code)) -ge $((0xA490)) && $((code)) -le $((0xA4CF)) ]] || \
           [[ $((code)) -ge $((0xA4D0)) && $((code)) -le $((0xA4FF)) ]] || \
           [[ $((code)) -ge $((0xA500)) && $((code)) -le $((0xA63F)) ]] || \
           [[ $((code)) -ge $((0xA640)) && $((code)) -le $((0xA69F)) ]] || \
           [[ $((code)) -ge $((0xA6A0)) && $((code)) -le $((0xA6FF)) ]] || \
           [[ $((code)) -ge $((0xA700)) && $((code)) -le $((0xA71F)) ]] || \
           [[ $((code)) -ge $((0xA720)) && $((code)) -le $((0xA7FF)) ]] || \
           [[ $((code)) -ge $((0xA800)) && $((code)) -le $((0xA82F)) ]] || \
           [[ $((code)) -ge $((0xA830)) && $((code)) -le $((0xA83F)) ]] || \
           [[ $((code)) -ge $((0xA840)) && $((code)) -le $((0xA87F)) ]] || \
           [[ $((code)) -ge $((0xA880)) && $((code)) -le $((0xA8DF)) ]] || \
           [[ $((code)) -ge $((0xA8E0)) && $((code)) -le $((0xA8FF)) ]] || \
           [[ $((code)) -ge $((0xA900)) && $((code)) -le $((0xA92F)) ]] || \
           [[ $((code)) -ge $((0xA930)) && $((code)) -le $((0xA95F)) ]] || \
           [[ $((code)) -ge $((0xA960)) && $((code)) -le $((0xA97F)) ]] || \
           [[ $((code)) -ge $((0xA980)) && $((code)) -le $((0xA9DF)) ]] || \
           [[ $((code)) -ge $((0xA9E0)) && $((code)) -le $((0xA9FF)) ]] || \
           [[ $((code)) -ge $((0xAA00)) && $((code)) -le $((0xAA5F)) ]] || \
           [[ $((code)) -ge $((0xAA60)) && $((code)) -le $((0xAA7F)) ]] || \
           [[ $((code)) -ge $((0xAA80)) && $((code)) -le $((0xAADF)) ]] || \
           [[ $((code)) -ge $((0xAAE0)) && $((code)) -le $((0xAAFF)) ]] || \
           [[ $((code)) -ge $((0xAB00)) && $((code)) -le $((0xAB2F)) ]] || \
           [[ $((code)) -ge $((0xAB30)) && $((code)) -le $((0xAB6F)) ]] || \
           [[ $((code)) -ge $((0xAB70)) && $((code)) -le $((0xABBF)) ]] || \
           [[ $((code)) -ge $((0xABC0)) && $((code)) -le $((0xABFF)) ]] || \
           [[ $((code)) -ge $((0xAC00)) && $((code)) -le $((0xD7AF)) ]] || \
           [[ $((code)) -ge $((0xD7B0)) && $((code)) -le $((0xD7FF)) ]] || \
           [[ $((code)) -ge $((0xD800)) && $((code)) -le $((0xDB7F)) ]] || \
           [[ $((code)) -ge $((0xDB80)) && $((code)) -le $((0xDBFF)) ]] || \
           [[ $((code)) -ge $((0xDC00)) && $((code)) -le $((0xDFFF)) ]] || \
           [[ $((code)) -ge $((0xE000)) && $((code)) -le $((0xF8FF)) ]] || \
           [[ $((code)) -ge $((0xF900)) && $((code)) -le $((0xFAFF)) ]] || \
           [[ $((code)) -ge $((0xFB00)) && $((code)) -le $((0xFB4F)) ]] || \
           [[ $((code)) -ge $((0xFB50)) && $((code)) -le $((0xFDFF)) ]] || \
           [[ $((code)) -ge $((0xFE00)) && $((code)) -le $((0xFE0F)) ]] || \
           [[ $((code)) -ge $((0xFE10)) && $((code)) -le $((0xFE1F)) ]] || \
           [[ $((code)) -ge $((0xFE20)) && $((code)) -le $((0xFE2F)) ]] || \
           [[ $((code)) -ge $((0xFE30)) && $((code)) -le $((0xFE4F)) ]] || \
           [[ $((code)) -ge $((0xFE50)) && $((code)) -le $((0xFE6F)) ]] || \
           [[ $((code)) -ge $((0xFE70)) && $((code)) -le $((0xFEFF)) ]] || \
           [[ $((code)) -ge $((0xFF00)) && $((code)) -le $((0xFFEF)) ]] || \
           [[ $((code)) -ge $((0xFFF0)) && $((code)) -le $((0xFFFF)) ]]; then
            width=$((width + 2))
        # Check for combining characters (zero width)
        elif [[ $((code)) -ge $((0x0300)) && $((code)) -le $((0x036F)) ]] || \
             [[ $((code)) -ge $((0x1AB0)) && $((code)) -le $((0x1AFF)) ]] || \
             [[ $((code)) -ge $((0x20D0)) && $((code)) -le $((0x20FF)) ]] || \
             [[ $((code)) -ge $((0xFE20)) && $((code)) -le $((0xFE2F)) ]] || \
             [[ $((code)) -ge $((0x1DC0)) && $((code)) -le $((0x1DFF)) ]]; then
            # Combining characters have zero width
            width=$width
        # Check for zero-width characters
        elif [[ $((code)) -eq $((0x200B)) ]] || [[ $((code)) -eq $((0x200C)) ]] || [[ $((code)) -eq $((0x200D)) ]] || \
             [[ $((code)) -eq $((0x2060)) ]] || [[ $((code)) -eq $((0xFEFF)) ]]; then
            # Zero-width characters
            width=$width
        else
            # Regular characters
            width=$((width + 1))
        fi

        i=$((i + 1))
    done

    echo "$width"
}

# Enhanced character repetition with Unicode support
repeat_char() {
    local char="$1" count="$2"
    local i
    for ((i=0; i<count; i++)); do
        printf "%s" "$char"
    done
}

# =============================================================================
# MODULAR EMOJI, COLOR, AND PADDING SYSTEM
# =============================================================================

# Centralized semantic emoji map
declare -A EMOJI_MAP=(
    # key = semantic_name, value = "emoji:width:spacing"
    ["success"]="✅:2:1"
    ["error"]="❌:2:1"
    ["warning"]="❗:2:1"
    ["pending"]="⏳:2:1"
    ["running"]="🔄:2:1"
    ["paused"]="⏸️:2:1"
    ["skip"]="⏭️:2:1"
    ["new"]="📋:2:1"
    ["timing"]="⏰:2:1"
    ["stats"]="📊:2:1"
    ["suggestion"]="💡:2:1"
    ["action"]="🎯:2:1"
    ["config"]="🔧:2:1"
    ["info"]="ℹ️:2:1"
    ["check"]="✓:1:1"
    ["cross"]="✗:1:1"
    ["arrow"]="→:1:1"
    ["bullet"]="•:1:1"
    ["star"]="★:1:1"
    ["heart"]="❤️:2:1"
    ["fire"]="🔥:2:1"
    ["rocket"]="🚀:2:1"
    ["sparkles"]="✨:2:1"
    ["thumbsup"]="👍:2:1"
    ["thumbsdown"]="👎:2:1"
)

# Color codes map
declare -A COLOR_MAP=(
    ["success"]="32"
    ["error"]="31"
    ["warning"]="33"
    ["info"]="36"
    ["pending"]="35"
    ["running"]="34"
    ["reset"]="0"
    ["bold"]="1"
    ["dim"]="2"
    ["underline"]="4"
    ["red"]="31"
    ["green"]="32"
    ["yellow"]="33"
    ["blue"]="34"
    ["magenta"]="35"
    ["cyan"]="36"
    ["white"]="37"
    ["gray"]="90"
)

# =============================================================================
# COMPONENT BUILDER FUNCTIONS
# =============================================================================

# Create an emoji component
make_emoji_component() {
    local key="$1"
    echo "emoji:$key"
}

# Create a text component
make_text_component() {
    local text="$1"
    echo "text:$text"
}

# Create a color component
make_color_component() {
    local color="$1"
    echo "color:$color"
}

# Create a spacing component
make_spacing_component() {
    local spaces="$1"
    echo "spacing:$spaces"
}

# =============================================================================
# COMPONENT RENDERING FUNCTIONS
# =============================================================================

# Get the display width of a component
get_component_width() {
    local component="$1"
    local type="${component%%:*}"
    local value="${component#*:}"
    
    case "$type" in
        "emoji")
            local emoji_data="${EMOJI_MAP[$value]}"
            if [[ -n "$emoji_data" ]]; then
                local emoji_width=$(echo "$emoji_data" | cut -d: -f2)
                local emoji_spacing=$(echo "$emoji_data" | cut -d: -f3)
                echo $((emoji_width + emoji_spacing))
            else
                echo "1"  # Default width for unknown emojis
            fi
            ;;
        "text")
            # Strip color codes and count Unicode characters
            local clean_text=$(strip_color_codes "$value")
            echo "${#clean_text}"
            ;;
        "spacing")
            echo "$value"
            ;;
        "color"|"reset")
            echo "0"  # Colors don't take display space
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Render a single component
render_component() {
    local component="$1"
    local type="${component%%:*}"
    local value="${component#*:}"
    
    case "$type" in
        "emoji")
            local emoji_data="${EMOJI_MAP[$value]}"
            if [[ -n "$emoji_data" ]]; then
                local emoji=$(echo "$emoji_data" | cut -d: -f1)
                local spacing=$(echo "$emoji_data" | cut -d: -f3)
                # Return emoji with its spacing
                printf "%s%*s" "$emoji" "$spacing" ""
            else
                echo "?"  # Fallback for unknown emojis
            fi
            ;;
        "text")
            echo "$value"
            ;;
        "color")
            local color_code="${COLOR_MAP[$value]}"
            if [[ -n "$color_code" ]]; then
                echo -e "\033[${color_code}m"
            fi
            ;;
        "spacing")
            printf '%*s' "$value" ''
            ;;
        *)
            echo "$value"
            ;;
    esac
}

# =============================================================================
# OUTPUT COMPOSER
# =============================================================================

# Compose a line from components with optional padding
compose_line() {
    local target_width="${1:-0}"
    shift
    local components=("$@")
    
    local result=""
    local current_width=0
    local current_color=""
    
    # Render all components and calculate total width
    for component in "${components[@]}"; do
        local type="${component%%:*}"
        local value="${component#*:}"
        
        case "$type" in
            "color")
                # Handle color codes specially
                local color_code="${COLOR_MAP[$value]}"
                if [[ -n "$color_code" ]]; then
                    if [[ "$value" == "reset" ]]; then
                        result="${result}\033[0m"
                        current_color=""
                    else
                        result="${result}\033[${color_code}m"
                        current_color="\033[${color_code}m"
                    fi
                fi
                ;;
            *)
                # Render other components normally
                local rendered=$(render_component "$component")
                local width=$(get_component_width "$component")
                
                result="${result}${rendered}"
                current_width=$((current_width + width))
                ;;
        esac
    done
    
    # Add padding if needed
    if [[ $target_width -gt $current_width ]]; then
        local padding_needed=$((target_width - current_width))
        result="${result}$(printf '%*s' "$padding_needed" '')"
    fi
    
    # Reset color at the end
    if [[ -n "$current_color" ]]; then
        result="${result}\033[0m"
    fi
    
    echo -e "$result"
}

# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

# Get emoji by key
get_emoji() {
    local key="$1"
    local emoji_data="${EMOJI_MAP[$key]}"
    if [[ -n "$emoji_data" ]]; then
        echo "$emoji_data" | cut -d: -f1
    else
        echo "?"
    fi
}

# Get emoji width by key
get_emoji_width() {
    local key="$1"
    local emoji_data="${EMOJI_MAP[$key]}"
    if [[ -n "$emoji_data" ]]; then
        echo "$emoji_data" | cut -d: -f2
    else
        echo "1"
    fi
}

# Get emoji spacing by key
get_emoji_spacing() {
    local key="$1"
    local emoji_data="${EMOJI_MAP[$key]}"
    if [[ -n "$emoji_data" ]]; then
        echo "$emoji_data" | cut -d: -f3
    else
        echo "1"
    fi
}

# Get color code by name
get_color_code() {
    local color_name="$1"
    echo "${COLOR_MAP[$color_name]:-0}"
}

# Create a formatted status line with proper alignment
create_status_line() {
    local status="$1"
    local message="$2"
    local count="${3:-}"
    
    local components=(
        "$(make_color_component "$status")"
        "$(make_emoji_component "$status")"
        "$(make_text_component "$message")"
    )
    
    if [[ -n "$count" ]]; then
        components+=(
            "$(make_spacing_component "2")"
            "$(make_text_component "($count)")"
        )
    fi
    
    components+=("$(make_color_component "reset")")
    
    compose_line 0 "${components[@]}"
}

# Create a table row with proper column alignment
create_table_row() {
    local target_width="$1"
    shift
    local columns=("$@")
    
    local components=()
    local first=true
    
    for column in "${columns[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            components+=("$(make_spacing_component "2")")
        fi
        components+=("$(make_text_component "$column")")
    done
    
    compose_line "$target_width" "${components[@]}"
}

# Create a header row with bold text and proper alignment
create_header_row() {
    local target_width="$1"
    shift
    local columns=("$@")
    
    local components=()
    local first=true
    
    for column in "${columns[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            components+=("$(make_spacing_component "2")")
        fi
        components+=("$(make_color_component "bold")")
        components+=("$(make_text_component "$column")")
        components+=("$(make_color_component "reset")")
    done
    
    compose_line "$target_width" "${components[@]}"
}

# Create a table row with emoji status and proper column alignment
create_status_table_row() {
    local target_width="$1"
    local module="$2"
    local last_run="$3"
    local status_type="$4"
    local status_text="$5"
    local next_due="$6"
    
    # Calculate column widths based on typical content
    local module_width=15
    local last_run_width=12
    local status_width=10
    local next_due_width=10
    
    # Pad each column to its target width
    local padded_module=$(printf "%-${module_width}s" "$module")
    local padded_last_run=$(printf "%-${last_run_width}s" "$last_run")
    local padded_status=$(printf "%-${status_width}s" "$(get_emoji "$status_type") $status_text")
    local padded_next_due=$(printf "%-${next_due_width}s" "$next_due")
    
    local components=(
        "$(make_text_component "$padded_module")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_last_run")"
        "$(make_spacing_component "2")"
        "$(make_color_component "$status_type")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_next_due")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# Create a header row with proper column alignment
create_aligned_header_row() {
    local target_width="$1"
    shift
    local columns=("$@")
    
    # Calculate column widths based on typical content
    local module_width=15
    local last_run_width=12
    local status_width=10
    local next_due_width=10
    
    # Pad each column to its target width
    local padded_module=$(printf "%-${module_width}s" "${columns[0]}")
    local padded_last_run=$(printf "%-${last_run_width}s" "${columns[1]}")
    local padded_status=$(printf "%-${status_width}s" "${columns[2]}")
    local padded_next_due=$(printf "%-${next_due_width}s" "${columns[3]}")
    
    local components=(
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_module")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_last_run")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_next_due")"
        "$(make_color_component "reset")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# Create a simple table row for 3-column layout (Package Manager, Status, Packages)
create_simple_table_row() {
    local target_width="$1"
    local package_manager="$2"
    local status_type="$3"
    local status_text="$4"
    local packages="$5"
    
    # Calculate column widths for 3-column layout
    local package_width=15
    local status_width=15  # Increased from 12 to 15 to accommodate emoji + text
    local packages_width=10
    
    # Pad each column to its target width
    local padded_package=$(printf "%-${package_width}s" "$package_manager")
    local padded_status=$(printf "%-${status_width}s" "$(get_emoji "$status_type") $status_text")
    local padded_packages=$(printf "%-${packages_width}s" "$packages")
    
    local components=(
        "$(make_text_component "$padded_package")"
        "$(make_spacing_component "2")"
        "$(make_color_component "$status_type")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_packages")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# Create a simple header row for 3-column layout
create_simple_header_row() {
    local target_width="$1"
    shift
    local columns=("$@")
    
    # Calculate column widths for 3-column layout
    local package_width=15
    local status_width=15  # Increased from 12 to 15 to match data rows
    local packages_width=10
    
    # Pad each column to its target width
    local padded_package=$(printf "%-${package_width}s" "${columns[0]}")
    local padded_status=$(printf "%-${status_width}s" "${columns[1]}")
    local padded_packages=$(printf "%-${packages_width}s" "${columns[2]}")
    
    local components=(
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_package")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_packages")"
        "$(make_color_component "reset")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# =============================================================================
# LEGACY COMPATIBILITY FUNCTIONS
# =============================================================================

# Legacy fix_emojis function (now deprecated, kept for compatibility)
fix_emojis() {
    local text="$1"
    # This function is now deprecated - use the modular system instead
    # For backward compatibility, we'll still do basic replacements
    text="${text//⚠️/!}"
    text="${text//⏭️/>}"
    text="${text//⏱️/*}"
    text="${text//🗑️/X}"
    text="${text//🖥️/@}"
    text="${text//⏸️/|}"
    echo "$text"
}

# Strip ANSI color codes for width calculation (still needed for legacy functions)
strip_color_codes() {
    local text="$1"
    # Remove ANSI color codes: \033[XXm or \033[XX;YYm
    echo "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# =============================================================================
# BOX DRAWING FUNCTIONS (Updated to use new system)
# =============================================================================

# Draw a box around text with optional title and color
draw_box() {
    local text="$1"
    local title="${2:-}"
    local color="${3:-}"
    local width="${4:-0}"
    
    # Calculate box width
    if [[ $width -eq 0 ]]; then
        width=$((${#text} + 4))  # text + padding
    fi
    
    # Get color codes
    local color_code=""
    local reset_code=""
    if [[ -n "$color" ]]; then
        local color_num="${COLOR_MAP[$color]}"
        if [[ -n "$color_num" ]]; then
            color_code="\033[${color_num}m"
            reset_code="\033[0m"
        fi
    fi
    
    # Build top border
    local top_border=""
    if [[ -n "$title" ]]; then
        # Title box: ┌─ Title ─┐
        # Account for the spaces around title: "─ $title ─" = title + 2 spaces
        local title_with_spaces=$((${#title} + 2))
        local title_padding=$((width - title_with_spaces - 4))
        if [[ $title_padding -gt 0 ]]; then
            local left_pad=$((title_padding / 2))
            local right_pad=$((title_padding - left_pad))
            # Build the border manually to preserve Unicode
            top_border="┌"
            for ((i=0; i<left_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}─ $title ─"
            for ((i=0; i<right_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}┐"
        else
            top_border="┌─ $title ─┐"
        fi
    else
        # Simple box: ┌─────┐
        top_border="┌"
        for ((i=0; i<width-2; i++)); do
            top_border="${top_border}─"
        done
        top_border="${top_border}┐"
    fi
    
    # Build content line
    local content_line="│ $text"
    local content_padding=$((width - ${#text} - 3))
    if [[ $content_padding -gt 0 ]]; then
        for ((i=0; i<content_padding; i++)); do
            content_line="${content_line} "
        done
        content_line="${content_line}│"
    else
        content_line="${content_line}│"
    fi
    
    # Build bottom border
    local bottom_border="└"
    for ((i=0; i<width-2; i++)); do
        bottom_border="${bottom_border}─"
    done
    bottom_border="${bottom_border}┘"
    
    # Output with colors
    echo -e "${color_code}${top_border}${reset_code}"
    echo -e "${color_code}${content_line}${reset_code}"
    echo -e "${color_code}${bottom_border}${reset_code}"
}

# Draw a colored status box
draw_status_box() {
    local status="$1"
    local text="$2"
    local title="${3:-}"
    
    # Map status to color
    local color=""
    case "$status" in
        "success") color="success" ;;
        "error") color="error" ;;
        "warning") color="warning" ;;
        "info") color="info" ;;
        "pending") color="pending" ;;
        "running") color="running" ;;
        *) color="info" ;;
    esac
    
    draw_box "$text" "$title" "$color"
}

# Calculate the display width of text (stripping color codes)
get_text_width() {
    local text="$1"
    local clean_text=$(strip_color_codes "$text")
    echo "${#clean_text}"
}

# Calculate the maximum width needed for a column based on all values
calculate_column_width() {
    local column_values=("$@")
    local max_width=0
    
    for value in "${column_values[@]}"; do
        local width=$(get_text_width "$value")
        if [[ $width -gt $max_width ]]; then
            max_width=$width
        fi
    done
    
    echo $max_width
}

# Create a table row with automatically calculated column widths
create_auto_table_row() {
    local target_width="$1"
    local column_widths=("${@:2:3}")  # First 3 widths
    shift 4  # Skip target_width and 3 widths
    local columns=("$@")
    
    local components=()
    local first=true
    
    for i in "${!columns[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            components+=("$(make_spacing_component "2")")
        fi
        
        local column_width="${column_widths[$i]}"
        local column_value="${columns[$i]}"
        local padded_column=$(printf "%-${column_width}s" "$column_value")
        components+=("$(make_text_component "$padded_column")")
    done
    
    compose_line "$target_width" "${components[@]}"
}

# Create a header row with automatically calculated column widths
create_auto_header_row() {
    local target_width="$1"
    local column_widths=("${@:2:3}")  # First 3 widths
    shift 4  # Skip target_width and 3 widths
    local columns=("$@")
    
    local components=()
    local first=true
    
    for i in "${!columns[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            components+=("$(make_spacing_component "2")")
        fi
        
        local column_width="${column_widths[$i]}"
        local padded_column=$(printf "%-${column_width}s" "${columns[$i]}")
        components+=("$(make_color_component "bold")")
        components+=("$(make_text_component "$padded_column")")
        components+=("$(make_color_component "reset")")
    done
    
    compose_line "$target_width" "${components[@]}"
}

# Create a status table row with automatically calculated column widths
create_auto_status_table_row() {
    local target_width="$1"
    local column_widths=("${@:2:4}")  # First 4 widths
    local module="$6"
    local last_run="$7"
    local status_type="$8"
    local status_text="$9"
    local next_due="${10}"
    
    # Create status text with emoji
    local status_with_emoji="$(get_emoji "$status_type") $status_text"
    
    # Pad each column to its calculated width
    local padded_module=$(printf "%-${column_widths[0]}s" "$module")
    local padded_last_run=$(printf "%-${column_widths[1]}s" "$last_run")
    local padded_status=$(printf "%-${column_widths[2]}s" "$status_with_emoji")
    local padded_next_due=$(printf "%-${column_widths[3]}s" "$next_due")
    
    local components=(
        "$(make_text_component "$padded_module")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_last_run")"
        "$(make_spacing_component "2")"
        "$(make_color_component "$status_type")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_next_due")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# Create a table row using the component system for proper emoji handling
create_component_table_row() {
    local target_width="$1"
    local module="$2"
    local status_type="$3"
    local status_text="$4"
    local packages="$5"
    
    # Calculate maximum column widths
    local max_module_width=$(calculate_column_width "Package Manager" "$module")
    local max_packages_width=$(calculate_column_width "Packages" "$packages")
    
    # For status column, calculate the actual maximum width needed
    # We need to calculate the width of emoji + space + text for each status type
    local emoji_width1=$(get_component_width "$(make_emoji_component "success")")
    local emoji_width2=$(get_component_width "$(make_emoji_component "warning")")
    local text_width1=$(get_text_width "Updated")
    local text_width2=$(get_text_width "Held")
    
    local status_width1=$((emoji_width1 + 1 + text_width1))  # ✅ Updated
    local status_width2=$((emoji_width2 + 1 + text_width2))  # ❗ Held
    
    local max_status_width=$((status_width1 > status_width2 ? status_width1 : status_width2))
    
    # Pad all columns to their maximum widths
    local padded_module=$(printf "%-${max_module_width}s" "$module")
    local padded_packages=$(printf "%-${max_packages_width}s" "$packages")
    
    # For status, we need to pad the text part to ensure consistent alignment
    local emoji_width=$(get_component_width "$(make_emoji_component "$status_type")")
    local text_width=$(get_text_width "$status_text")
    local current_status_width=$((emoji_width + 1 + text_width))  # emoji + space + text
    local status_padding=$((max_status_width - current_status_width))
    
    # Build components using the component system
    local components=(
        "$(make_text_component "$padded_module")"
        "$(make_spacing_component "2")"
        "$(make_emoji_component "$status_type")"
        "$(make_spacing_component "1")"
        "$(make_text_component "$status_text")"
    )
    
    # Add padding after status text if needed
    if [[ $status_padding -gt 0 ]]; then
        components+=("$(make_spacing_component "$status_padding")")
    fi
    
    components+=(
        "$(make_spacing_component "2")"
        "$(make_text_component "$padded_packages")"
    )
    
    compose_line "$target_width" "${components[@]}"
}

# Create a header row using the component system
create_component_header_row() {
    local target_width="$1"
    local module_width="$2"
    local status_width="$3"
    local packages_width="$4"
    
    # Pad headers to match data column widths
    local padded_module=$(printf "%-${module_width}s" "Package Manager")
    local padded_status=$(printf "%-${status_width}s" "Status")
    local padded_packages=$(printf "%-${packages_width}s" "Packages")
    
    local components=(
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_module")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_packages")"
        "$(make_color_component "reset")"
    )
    
    compose_line "$target_width" "${components[@]}"
}
