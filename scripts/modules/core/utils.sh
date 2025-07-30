#!/bin/bash
# utils.sh - Enhanced utility functions for box drawing, styling, and visual feedback
# Implements Taskmaster-inspired visual design with terminal-first dark theme

# =============================================================================
# TERMINAL-FIRST DARK THEME DOCUMENTATION
# =============================================================================
#
# This file implements a comprehensive terminal-first dark theme with:
#
# 1. SEMANTIC COLOR PALETTE:
#    - PRIMARY_BG (#1a1a1a): Deep black background for terminal-first design
#    - PRIMARY_FG (#f8f8f2): High-contrast white text for readability
#    - ACCENT_CYAN (#8be9fd): Headers, section dividers, emphasis
#    - ACCENT_MAGENTA (#bd93f9): Progress indicators, special emphasis
#    - SUCCESS_GREEN (#50fa7b): Completed tasks, successful operations
#    - WARNING_YELLOW (#f1fa8c): Skipped tasks, pending actions
#    - ERROR_RED (#ff5555): Failed operations, critical issues
#    - INFO_BLUE (#6272a4): Informational content, metadata
#
# 2. COLORBLIND ACCESSIBILITY:
#    - Environment variable: UPKEP_COLORBLIND=1 or UPKEP_COLORBLIND=true
#    - Alternative high-contrast colors for colorblind users
#    - Text indicators ([SUCCESS], [ERROR], etc.) when colorblind mode is active
#    - Emoji indicators work alongside colors for additional visual cues
#
# 3. TERMINAL COMPATIBILITY:
#    - Automatic detection of 24-bit, 256, 8-color, or no-color terminals
#    - Graceful fallback to appropriate color support
#    - Unicode-aware width calculation for proper alignment
#
# 4. USAGE EXAMPLES:
#    # Basic status line with semantic colors
#    create_status_line "success" "Task completed" "45"
#
#    # Themed section header with accent colors
#    create_section_header "System Update"
#
#    # Colorblind-friendly status line
#    export UPKEP_COLORBLIND=1
#    create_accessible_status_line "success" "Task completed" "45"
#
#    # Themed status box
#    create_themed_status_box "success" "Update Complete" "All packages updated successfully"
#
# =============================================================================

# =============================================================================
# COLOR SYSTEM - Terminal-first dark theme with semantic color palette
# =============================================================================

# Base ANSI escape codes
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
REVERSE="\033[7m"
HIDDEN="\033[8m"

# Legacy color support (8-bit)
WHITE="\033[97m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
GRAY="\033[90m"

# Enhanced color palette from DESIGN.md
# Primary colors for terminal-first dark theme
PRIMARY_BG="\033[48;2;26;26;26m"    # #1a1a1a - Deep black background
PRIMARY_FG="\033[38;2;248;248;242m" # #f8f8f2 - High-contrast white text
ACCENT_CYAN="\033[38;2;139;233;253m"   # #8be9fd - Headers, section dividers
ACCENT_MAGENTA="\033[38;2;189;147;249m" # #bd93f9 - Progress, emphasis

# Semantic status colors (colorblind-friendly alternatives)
SUCCESS_GREEN="\033[38;2;80;250;123m"   # #50fa7b - Completed tasks, successful operations
WARNING_YELLOW="\033[38;2;241;250;140m" # #f1fa8c - Skipped tasks, pending actions
ERROR_RED="\033[38;2;255;85;85m"        # #ff5555 - Failed operations, critical issues
INFO_BLUE="\033[38;2;98;114;164m"       # #6272a4 - Informational content, metadata

# Colorblind-friendly alternatives (high contrast)
PRIMARY_FG_ALT="\033[38;2;255;255;255m" # #ffffff - Pure white for maximum contrast
ACCENT_CYAN_ALT="\033[38;2;0;255;255m"  # #00ffff - Bright cyan for high contrast
ACCENT_MAGENTA_ALT="\033[38;2;255;0;255m" # #ff00ff - Bright magenta for high contrast
SUCCESS_GREEN_ALT="\033[38;2;0;215;0m"  # #00d700 - Bright green, distinct from red
WARNING_YELLOW_ALT="\033[38;2;255;215;0m" # #ffd700 - Golden yellow, high contrast
ERROR_RED_ALT="\033[38;2;255;0;0m"      # #ff0000 - Pure red, maximum contrast
INFO_BLUE_ALT="\033[38;2;0;135;255m"    # #0087ff - Bright blue, distinct

# =============================================================================
# COLOR DETECTION AND FALLBACK SYSTEM
# =============================================================================

# Detect colorblind mode from environment variable or config file
is_colorblind_mode() {
    # Check environment variable first (highest priority)
    if [[ "${UPKEP_COLORBLIND:-0}" == "1" ]] || [[ "${UPKEP_COLORBLIND:-0}" == "true" ]]; then
        return 0
    fi

    # Check config file if environment variable is not set
    if [[ -z "${UPKEP_COLORBLIND:-}" ]]; then
        # Try to get from config file (only if config system is available)
        if command -v get_colorblind_enabled >/dev/null 2>&1; then
            if get_colorblind_enabled; then
                return 0
            fi
        fi
    fi

    return 1
}

# Detect terminal color support
detect_color_support() {
    local colors=8  # Default fallback

    # Try to get colors if tput exists
    if command -v tput >/dev/null 2>&1; then
        # Try to get colors with a simple approach
        colors=$(tput colors 2>/dev/null || echo 8)
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

# Get color code with fallback support and colorblind mode
get_color() {
    local color_name="$1"
    local color_support=$(detect_color_support)

    # Check colorblind mode properly
    local colorblind=false
    if is_colorblind_mode; then
        colorblind=true
    fi

    case "$color_support" in
        "24bit")
            case "$color_name" in
                "primary_bg") echo "$PRIMARY_BG" ;;
                "primary_fg")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$PRIMARY_FG_ALT"
                    else
                        echo "$PRIMARY_FG"
                    fi
                    ;;
                "accent_cyan")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$ACCENT_CYAN_ALT"
                    else
                        echo "$ACCENT_CYAN"
                    fi
                    ;;
                "accent_magenta")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$ACCENT_MAGENTA_ALT"
                    else
                        echo "$ACCENT_MAGENTA"
                    fi
                    ;;
                "success")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$SUCCESS_GREEN_ALT"
                    else
                        echo "$SUCCESS_GREEN"
                    fi
                    ;;
                "warning")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$WARNING_YELLOW_ALT"
                    else
                        echo "$WARNING_YELLOW"
                    fi
                    ;;
                "error")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$ERROR_RED_ALT"
                    else
                        echo "$ERROR_RED"
                    fi
                    ;;
                "info")
                    if [[ "$colorblind" == "true" ]]; then
                        echo "$INFO_BLUE_ALT"
                    else
                        echo "$INFO_BLUE"
                    fi
                    ;;
                *) echo "$WHITE" ;;
            esac
            ;;
        "256"|"8")
            case "$color_name" in
                "success") echo "$GREEN" ;;
                "warning") echo "$YELLOW" ;;
                "error") echo "$RED" ;;
                "info") echo "$BLUE" ;;
                "accent_cyan") echo "$CYAN" ;;
                "accent_magenta") echo "$MAGENTA" ;;
                *) echo "$WHITE" ;;
            esac
            ;;
        *)
            echo "" # No color support
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
    # Semantic theme colors (will be handled by get_color function)
    ["primary_bg"]="primary_bg"
    ["primary_fg"]="primary_fg"
    ["accent_cyan"]="accent_cyan"
    ["accent_magenta"]="accent_magenta"
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
            # Handle semantic theme colors and legacy colors
            case "$value" in
                "primary_bg"|"primary_fg"|"accent_cyan"|"accent_magenta"|"success"|"warning"|"error"|"info")
                    # Use get_color function for semantic colors
                    printf "%b" "$(get_color "$value")"
                    ;;
                *)
                    # Use legacy COLOR_MAP for other colors
                    local color_code="${COLOR_MAP[$value]}"
                    if [[ -n "$color_code" ]]; then
                        echo -e "\033[${color_code}m"
                    fi
                    ;;
            esac
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
                case "$value" in
                    "primary_bg"|"primary_fg"|"accent_cyan"|"accent_magenta"|"success"|"warning"|"error"|"info")
                        # Use get_color function for semantic colors
                        local color_code=$(get_color "$value")
                        if [[ "$value" == "reset" ]]; then
                            result="${result}\033[0m"
                            current_color=""
                        else
                            result="${result}${color_code}"
                            current_color="${color_code}"
                        fi
                        ;;
                    *)
                        # Handle legacy colors
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
                esac
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
        components+=("$(make_color_component "accent_cyan")")
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
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_module")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_last_run")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
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
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_package")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_packages")"
        "$(make_color_component "reset")"
    )

    compose_line "$target_width" "${components[@]}"
}

# =============================================================================
# THEMED OUTPUT FUNCTIONS
# =============================================================================

# Create a themed section header with accent colors
create_section_header() {
    local title="$1"
    local width="${2:-0}"

    if [[ $width -eq 0 ]]; then
        width=$(get_terminal_width)
    fi

    # Calculate padding for centering
    local title_length=${#title}
    local padding=$(( (width - title_length - 4) / 2 ))

    local components=(
        "$(make_color_component "accent_cyan")"
        "$(make_text_component "$(printf '%*s' "$padding" '')")"
        "$(make_text_component "── $title ──")"
        "$(make_color_component "reset")"
    )

    compose_line "$width" "${components[@]}"
}

# Create a themed divider line
create_divider() {
    local width="${1:-0}"
    local style="${2:-single}"

    if [[ $width -eq 0 ]]; then
        width=$(get_terminal_width)
    fi

    local divider_char
    case "$style" in
        "double") divider_char="═" ;;
        "thick") divider_char="━" ;;
        "dotted") divider_char="┄" ;;
        *) divider_char="─" ;;
    esac

    local components=(
        "$(make_color_component "accent_magenta")"
        "$(make_text_component "$(repeat_char "$divider_char" "$width")")"
        "$(make_color_component "reset")"
    )

    compose_line "$width" "${components[@]}"
}

# Create a themed status box with primary colors
create_themed_status_box() {
    local status="$1"
    local title="$2"
    local message="$3"
    local width="${4:-0}"

    if [[ $width -eq 0 ]]; then
        width=$(get_box_width)
    fi

    # Create box with status-appropriate colors
    local box_color
    case "$status" in
        "success") box_color="success" ;;
        "error") box_color="error" ;;
        "warning") box_color="warning" ;;
        "info") box_color="info" ;;
        *) box_color="accent_cyan" ;;
    esac

    # Top border with title
    local top_border=""
    if [[ -n "$title" ]]; then
        local title_with_spaces=$((${#title} + 4))  # "─ $title ─"
        local title_padding=$((width - title_with_spaces - 2))
        if [[ $title_padding -gt 0 ]]; then
            local left_pad=$((title_padding / 2))
            local right_pad=$((title_padding - left_pad))
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
        top_border="┌"
        for ((i=0; i<width-2; i++)); do
            top_border="${top_border}─"
        done
        top_border="${top_border}┐"
    fi

    # Content line
    local content_line="│ $message"
    local content_padding=$((width - ${#message} - 3))
    if [[ $content_padding -gt 0 ]]; then
        for ((i=0; i<content_padding; i++)); do
            content_line="${content_line} "
        done
        content_line="${content_line}│"
    else
        content_line="${content_line}│"
    fi

    # Bottom border
    local bottom_border="└"
    for ((i=0; i<width-2; i++)); do
        bottom_border="${bottom_border}─"
    done
    bottom_border="${bottom_border}┘"

    # Output with themed colors
    local components_top=(
        "$(make_color_component "$box_color")"
        "$(make_text_component "$top_border")"
        "$(make_color_component "reset")"
    )

    local components_content=(
        "$(make_color_component "$box_color")"
        "$(make_text_component "$content_line")"
        "$(make_color_component "reset")"
    )

    local components_bottom=(
        "$(make_color_component "$box_color")"
        "$(make_text_component "$bottom_border")"
        "$(make_color_component "reset")"
    )

    compose_line "$width" "${components_top[@]}"
    compose_line "$width" "${components_content[@]}"
    compose_line "$width" "${components_bottom[@]}"
}

# =============================================================================
# ACCESSIBILITY FUNCTIONS
# =============================================================================

# Get alternative visual indicator for colorblind users
get_colorblind_indicator() {
    local status="$1"
    local colorblind=$(is_colorblind_mode)

    if [[ "$colorblind" == "true" ]]; then
        case "$status" in
            "success") echo "[SUCCESS]" ;;
            "error") echo "[ERROR]" ;;
            "warning") echo "[WARNING]" ;;
            "info") echo "[INFO]" ;;
            "pending") echo "[PENDING]" ;;
            "running") echo "[RUNNING]" ;;
            *) echo "[$status]" ;;
        esac
    else
        echo ""
    fi
}

# Create a colorblind-friendly status line with text indicators
create_accessible_status_line() {
    local status="$1"
    local message="$2"
    local count="${3:-}"

    local colorblind_indicator=$(get_colorblind_indicator "$status")

    local components=(
        "$(make_color_component "$status")"
        "$(make_emoji_component "$status")"
        "$(make_text_component "$colorblind_indicator")"
        "$(make_spacing_component "1")"
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

    # Get color codes using get_color function for proper colorblind support
    local color_code=""
    local reset_code=""
    if [[ -n "$color" ]]; then
        color_code=$(get_color "$color")
        reset_code="\033[0m"
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

# =============================================================================
# ENHANCED EXECUTION SUMMARY BOXES
# =============================================================================

# Draw an enhanced execution summary box with multi-line content
draw_execution_summary_box() {
    local status="$1"
    local title="$2"
    shift 2
    local content_lines=("$@")

    # Map status to color using the modular system COLOR_MAP
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

    # Calculate box width
    local width=$(get_box_width)

    # Build top border with title
    local top_border=""
    if [[ -n "$title" ]]; then
        # Get emoji and calculate total title width
        local emoji=$(get_emoji "$status")
        local emoji_width=$(get_emoji_width "$status")
        local title_with_emoji="$emoji $title"
        local title_width=$(get_text_width "$title_with_emoji")

        # Calculate padding for centering
        local total_padding=$((width - title_width - 4))  # Account for borders and dashes
        if [[ $total_padding -gt 0 ]]; then
            local left_pad=$((total_padding / 2))
            local right_pad=$((total_padding - left_pad))

            top_border="┌"
            for ((i=0; i<left_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}─ $title_with_emoji ─"
            for ((i=0; i<right_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}┐"
        else
            # Fallback for very short width
            top_border="┌─ $title_with_emoji ─┐"
        fi
    else
        # Simple top border without title
        top_border="┌"
        for ((i=0; i<width-2; i++)); do
            top_border="${top_border}─"
        done
        top_border="${top_border}┐"
    fi

    # Build content lines with proper emoji handling
    local content_lines_formatted=()
    for line in "${content_lines[@]}"; do
        if [[ -n "$line" ]]; then
            # Process the line to handle emojis properly
            local processed_line=$(process_line_for_emojis "$line")
            local content_line="│ $processed_line"
            local content_width=$(get_text_width "$processed_line")
            local padding_needed=$((width - content_width - 3))  # Account for "│ " and "│"

            if [[ $padding_needed -gt 0 ]]; then
                for ((i=0; i<padding_needed; i++)); do
                    content_line="${content_line} "
                done
            fi
            content_line="${content_line}│"
            content_lines_formatted+=("$content_line")
        else
            # Empty line for spacing
            local empty_line="│"
            for ((i=0; i<width-2; i++)); do
                empty_line="${empty_line} "
            done
            empty_line="${empty_line}│"
            content_lines_formatted+=("$empty_line")
        fi
    done

    # Build bottom border
    local bottom_border="└"
    for ((i=0; i<width-2; i++)); do
        bottom_border="${bottom_border}─"
    done
    bottom_border="${bottom_border}┘"

    # Output using the modular system with COLOR_MAP
    local components_top=(
        "$(make_color_component "$color")"
        "$(make_text_component "$top_border")"
        "$(make_color_component "reset")"
    )
    compose_line "$width" "${components_top[@]}"

    # Output content lines
    for content_line in "${content_lines_formatted[@]}"; do
        local components_content=(
            "$(make_color_component "$color")"
            "$(make_text_component "$content_line")"
            "$(make_color_component "reset")"
        )
        compose_line "$width" "${components_content[@]}"
    done

    # Output bottom border
    local components_bottom=(
        "$(make_color_component "$color")"
        "$(make_text_component "$bottom_border")"
        "$(make_color_component "reset")"
    )
    compose_line "$width" "${components_bottom[@]}"
}

# Helper function to process lines and handle emojis properly
process_line_for_emojis() {
    local line="$1"

    # Replace common emoji patterns with proper emoji components
    # This is a simple implementation - in a full system, you'd want more sophisticated parsing
    line="${line//✅/$(get_emoji "success")}"
    line="${line//❌/$(get_emoji "error")}"
    line="${line//⚠️/$(get_emoji "warning")}"
    line="${line//⏳/$(get_emoji "pending")}"
    line="${line//🔄/$(get_emoji "running")}"
    line="${line//💡/$(get_emoji "info")}"
    line="${line//📦/📦}"  # Package emoji
    line="${line//⏱️/⏱️}"  # Timer emoji
    line="${line//📅/📅}"  # Calendar emoji
    line="${line//⏭️/⏭️}"  # Skip emoji
    line="${line//🔍/🔍}"  # Search emoji
    line="${line//💾/💾}"  # Save emoji

    echo "$line"
}

# Draw a success execution summary box
draw_success_summary_box() {
    local title="$1"
    local message="$2"
    local details="${3:-}"
    local count="${4:-}"

    local content_lines=()
    content_lines+=("$message")

    if [[ -n "$details" ]]; then
        content_lines+=("")
        content_lines+=("$details")
    fi

    if [[ -n "$count" ]]; then
        content_lines+=("")
        content_lines+=("Total: $count")
    fi

    draw_execution_summary_box "success" "$title" "${content_lines[@]}"
}

# Draw an error execution summary box
draw_error_summary_box() {
    local title="$1"
    local message="$2"
    local details="${3:-}"
    local count="${4:-}"

    local content_lines=()
    content_lines+=("$message")

    if [[ -n "$details" ]]; then
        content_lines+=("")
        content_lines+=("$details")
    fi

    if [[ -n "$count" ]]; then
        content_lines+=("")
        content_lines+=("Failed: $count")
    fi

    draw_execution_summary_box "error" "$title" "${content_lines[@]}"
}

# Draw a warning execution summary box
draw_warning_summary_box() {
    local title="$1"
    local message="$2"
    local details="${3:-}"
    local count="${4:-}"

    local content_lines=()
    content_lines+=("$message")

    if [[ -n "$details" ]]; then
        content_lines+=("")
        content_lines+=("$details")
    fi

    if [[ -n "$count" ]]; then
        content_lines+=("")
        content_lines+=("Held: $count")
    fi

    draw_execution_summary_box "warning" "$title" "${content_lines[@]}"
}

# Draw an info execution summary box
draw_info_summary_box() {
    local title="$1"
    local message="$2"
    local details="${3:-}"
    local count="${4:-}"

    local content_lines=()
    content_lines+=("$message")

    if [[ -n "$details" ]]; then
        content_lines+=("")
        content_lines+=("$details")
    fi

    if [[ -n "$count" ]]; then
        content_lines+=("")
        content_lines+=("Count: $count")
    fi

    draw_execution_summary_box "info" "$title" "${content_lines[@]}"
}

# =============================================================================
# LEGACY COMPATIBILITY - Enhanced draw_status_box
# =============================================================================

# Enhanced draw_status_box with backward compatibility
draw_status_box() {
    local status="$1"
    local text="$2"
    local title="${3:-}"

    # For backward compatibility, use the simple single-line version
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
        components+=("$(make_color_component "accent_cyan")")
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
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_module")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_status")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_packages")"
        "$(make_color_component "reset")"
    )

    compose_line "$target_width" "${components[@]}"
}

# =============================================================================
# HIERARCHICAL TABLE FUNCTIONS - Module Overview Table with Hierarchical Display
# =============================================================================

# Create a hierarchical table row with proper indentation
create_hierarchical_row() {
    local target_width="$1"
    local indent_level="$2"  # 0 = category header, 1 = first child, 2 = last child
    local module="$3"
    local last_run="$4"
    local status_type="$5"
    local status_text="$6"
    local next_due="$7"

    # Calculate column widths based on typical content
    local module_width=20
    local last_run_width=12
    local status_width=10
    local next_due_width=10

    # Create indentation prefix
    local indent_prefix=""
    case "$indent_level" in
        0)  # Category header - no indentation
            indent_prefix=""
            ;;
        1)  # First child - ├─ prefix
            indent_prefix="├─ "
            ;;
        2)  # Last child - └─ prefix
            indent_prefix="└─ "
            ;;
        *)  # Default to no indentation
            indent_prefix=""
            ;;
    esac

    # Pad each column to its target width
    local padded_module=$(printf "%-${module_width}s" "${indent_prefix}${module}")
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

# Create a category header row for module groups
create_category_header() {
    local target_width="$1"
    local category_name="$2"

    # Calculate column widths
    local module_width=20
    local last_run_width=12
    local status_width=10
    local next_due_width=10

    # Pad category name to module column width
    local padded_category=$(printf "%-${module_width}s" "$category_name")
    local empty_last_run=$(printf "%-${last_run_width}s" "")
    local empty_status=$(printf "%-${status_width}s" "")
    local empty_next_due=$(printf "%-${next_due_width}s" "")

    local components=(
        "$(make_color_component "accent_cyan")"
        "$(make_color_component "bold")"
        "$(make_text_component "$padded_category")"
        "$(make_color_component "reset")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$empty_last_run")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$empty_status")"
        "$(make_spacing_component "2")"
        "$(make_text_component "$empty_next_due")"
    )

    compose_line "$target_width" "${components[@]}"
}

# Create a bordered table with Unicode box-drawing characters
create_bordered_table() {
    local title="$1"
    local width="${2:-0}"
    shift 2
    local rows=("$@")

    # Calculate table width if not provided
    if [[ $width -eq 0 ]]; then
        width=$(get_terminal_width)
        # Ensure minimum width for table content
        if [[ $width -lt 80 ]]; then
            width=80
        fi
    fi

    # Calculate content width (table width minus borders)
    local content_width=$((width - 4))  # Account for left and right borders

    # Build top border with title
    local top_border=""
    if [[ -n "$title" ]]; then
        # Title box: ╭─ Title ─╮
        local title_with_spaces=$((${#title} + 2))
        local title_padding=$((content_width - title_with_spaces))
        if [[ $title_padding -gt 0 ]]; then
            local left_pad=$((title_padding / 2))
            local right_pad=$((title_padding - left_pad))
            top_border="╭"
            for ((i=0; i<left_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}─ $title ─"
            for ((i=0; i<right_pad; i++)); do
                top_border="${top_border}─"
            done
            top_border="${top_border}╮"
        else
            top_border="╭─ $title ─╮"
        fi
    else
        # Simple box: ╭─────╮
        top_border="╭"
        for ((i=0; i<content_width; i++)); do
            top_border="${top_border}─"
        done
        top_border="${top_border}╮"
    fi

    # Build header separator
    local header_separator="├"
    for ((i=0; i<content_width; i++)); do
        header_separator="${header_separator}─"
    done
    header_separator="${header_separator}┤"

    # Build bottom border
    local bottom_border="╰"
    for ((i=0; i<content_width; i++)); do
        bottom_border="${bottom_border}─"
    done
    bottom_border="${bottom_border}╯"

    # Output table with colors
    local color_code=$(get_color "accent_cyan")
    local reset_code="\033[0m"

    echo -e "${color_code}${top_border}${reset_code}"

    # Output header row
    if [[ ${#rows[@]} -gt 0 ]]; then
        echo -e "${color_code}│${reset_code} ${rows[0]} ${color_code}│${reset_code}"

        # Output header separator if there are data rows
        if [[ ${#rows[@]} -gt 1 ]]; then
            echo -e "${color_code}${header_separator}${reset_code}"
        fi

        # Output data rows
        for ((i=1; i<${#rows[@]}; i++)); do
            echo -e "${color_code}│${reset_code} ${rows[$i]} ${color_code}│${reset_code}"
        done
    fi

    echo -e "${color_code}${bottom_border}${reset_code}"
}

# Create a complete module overview table with hierarchical display
create_module_overview_table() {
    local title="${1:-SYSTEM MAINTENANCE STATUS}"
    local width="${2:-0}"

    # Calculate table width if not provided
    if [[ $width -eq 0 ]]; then
        width=$(get_terminal_width)
        # Ensure minimum width for table content
        if [[ $width -lt 80 ]]; then
            width=80
        fi
    fi

    # Calculate content width (table width minus borders and padding)
    local content_width=$((width - 6))  # Account for borders and padding

    # Create header row
    local header_row=$(create_aligned_header_row "$content_width" "Module" "Last Run" "Status" "Next Due")

    # Build the complete table structure
    local table_rows=("$header_row")

    # Example data structure - this would be populated with actual module data
    # Package Updates category
    table_rows+=("$(create_category_header "$content_width" "Package Updates")")
    table_rows+=("$(create_hierarchical_row "$content_width" "1" "APT" "2 days ago" "success" "Done" "5 days")")
    table_rows+=("$(create_hierarchical_row "$content_width" "1" "Snap" "2 days ago" "success" "Done" "5 days")")
    table_rows+=("$(create_hierarchical_row "$content_width" "2" "Flatpak" "6 days ago" "warning" "Due" "Now")")

    # System Cleanup category
    table_rows+=("$(create_category_header "$content_width" "System Cleanup")")
    table_rows+=("$(create_hierarchical_row "$content_width" "1" "Package Cache" "1 day ago" "success" "Done" "2 days")")
    table_rows+=("$(create_hierarchical_row "$content_width" "2" "Temp Files" "4 days ago" "warning" "Due" "Now")")

    # Custom Modules category
    table_rows+=("$(create_category_header "$content_width" "Custom Modules")")
    table_rows+=("$(create_hierarchical_row "$content_width" "2" "Docker Cleanup" "Never" "info" "New" "Setup")")

    # Create the bordered table
    create_bordered_table "$title" "$width" "${table_rows[@]}"
}

# Create a module overview table with custom data
create_custom_module_overview_table() {
    local title="${1:-SYSTEM MAINTENANCE STATUS}"
    local width="${2:-0}"
    shift 2
    local categories=("$@")

    # Calculate table width if not provided
    if [[ $width -eq 0 ]]; then
        width=$(get_terminal_width)
        # Ensure minimum width for table content
        if [[ $width -lt 80 ]]; then
            width=80
        fi
    fi

    # Calculate content width (table width minus borders and padding)
    local content_width=$((width - 6))  # Account for borders and padding

    # Create header row
    local header_row=$(create_aligned_header_row "$content_width" "Module" "Last Run" "Status" "Next Due")

    # Build the complete table structure
    local table_rows=("$header_row")

    # Process each category
    for category in "${categories[@]}"; do
        # Parse category data (format: "CategoryName:Module1:status1:Module2:status2:...")
        IFS=':' read -ra category_parts <<< "$category"
        local category_name="${category_parts[0]}"

        # Add category header
        table_rows+=("$(create_category_header "$content_width" "$category_name")")

        # Process modules in this category
        local module_count=$((${#category_parts[@]} - 1))
        for ((i=1; i<${#category_parts[@]}; i+=4)); do
            local module="${category_parts[$i]}"
            local last_run="${category_parts[$i+1]:-Never}"
            local status_type="${category_parts[$i+2]:-info}"
            local status_text="${category_parts[$i+3]:-New}"
            local next_due="${category_parts[$i+4]:-Setup}"

            # Determine indentation level (1 for first, 2 for last)
            local indent_level="1"
            if [[ $i -eq $((module_count - 3)) ]]; then
                indent_level="2"  # Last module in category
            fi

            table_rows+=("$(create_hierarchical_row "$content_width" "$indent_level" "$module" "$last_run" "$status_type" "$status_text" "$next_due")")
        done
    done

    # Create the bordered table
    create_bordered_table "$title" "$width" "${table_rows[@]}"
}

# Helper function to add a category to the module overview table
add_category_to_table() {
    local category_name="$1"
    local target_width="$2"

    # Add category header
    local category_row=$(create_category_header "$target_width" "$category_name")
    echo "$category_row"
}

# Helper function to add a module row to the table
add_module_to_table() {
    local indent_level="$1"  # 0 = category, 1 = first child, 2 = last child
    local module="$2"
    local last_run="$3"
    local status_type="$4"
    local status_text="$5"
    local next_due="$6"
    local target_width="$7"

    # Add module row with proper indentation
    local module_row=$(create_hierarchical_row "$target_width" "$indent_level" "$module" "$last_run" "$status_type" "$status_text" "$next_due")
    echo "$module_row"
}

# =============================================================================
# LEGACY BRIDGE - Layout Builder Compatibility Layer
# =============================================================================
# 
# This section provides compatibility for existing scripts using legacy box functions.
# These functions proxy to the new Layout Builder system with deprecation warnings.
# Legacy support will be maintained until v3.1, then deprecated in v3.2.
#
# DEPRECATION SCHEDULE:
# - v3.0.x: Legacy functions work with deprecation warnings
# - v3.1.x: Legacy functions emit stronger warnings
# - v3.2.x: Legacy functions removed
#
# MIGRATION GUIDE:
# - Replace draw_box() calls with JSON descriptors + render_layout_from_json()
# - Replace create_themed_status_box() with box_new() + box_render() DSL
# - Use new palette system for consistent colors and emoji
# =============================================================================

# Source the new Layout Builder components
_layout_builder_source() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd)"
    if [[ -f "${script_dir}/palette.sh" ]]; then
        source "${script_dir}/palette.sh" 2>/dev/null || true
    fi
    if [[ -f "${script_dir}/box_builder.sh" ]]; then
        source "${script_dir}/box_builder.sh" 2>/dev/null || true
    fi
    if [[ -f "${script_dir}/layout_loader.sh" ]]; then
        source "${script_dir}/layout_loader.sh" 2>/dev/null || true
    fi
}

# Legacy bridge: create_box() - Proxy to new Layout Builder
create_box() {
    local title="${1:-}"
    local style="${2:-info}"
    local width="${3:-0}"
    
    # Emit deprecation warning
    echo "WARNING: create_box() is deprecated. Use box_new() + box_render() from Layout Builder instead." >&2
    echo "  Migration: box_id=\$(box_new width title style); box_render \$box_id" >&2
    
    # Source Layout Builder if available
    _layout_builder_source
    
    # Proxy to new system if available
    if command -v box_new >/dev/null 2>&1 && command -v box_render >/dev/null 2>&1; then
        if [[ "$width" == "0" ]]; then
            width=$((COLUMNS - 2))
        fi
        local box_id
        box_id=$(box_new "$width" "$title" "$style")
        box_render "$box_id"
    else
        # Fallback to legacy implementation
        echo "Layout Builder not available, using legacy fallback" >&2
        draw_box "" "$title" "$style" "$width"
    fi
}

# Legacy bridge: create_summary_box() - Proxy to new Layout Builder
create_summary_box() {
    local status="$1"
    local title="$2"
    local message="$3"
    local width="${4:-0}"
    
    # Emit deprecation warning
    echo "WARNING: create_summary_box() is deprecated. Use JSON descriptors + render_layout_from_json() instead." >&2
    echo "  Migration: Use JSON layout descriptors with the new Layout Builder" >&2
    
    # Source Layout Builder if available
    _layout_builder_source
    
    # Proxy to new system if available
    if command -v render_layout_from_json >/dev/null 2>&1; then
        if [[ "$width" == "0" ]]; then
            width=$((COLUMNS - 2))
        fi
        
        # Create JSON descriptor
        local json_descriptor="{
            \"title\": \"$title\",
            \"style\": \"$status\",
            \"width\": $width,
            \"rows\": [
                {
                    \"cells\": [
                        {\"emoji\": \"$status\"},
                        {\"text\": \"$message\"}
                    ]
                }
            ]
        }"
        
        echo "$json_descriptor" | render_layout_from_stdin
    else
        # Fallback to legacy implementation
        echo "Layout Builder not available, using legacy fallback" >&2
        create_themed_status_box "$status" "$title" "$message" "$width"
    fi
}

# Legacy bridge: draw_status_box() - Proxy to new Layout Builder
draw_status_box() {
    local text="$1"
    local title="${2:-}"
    local color="${3:-info}"
    local width="${4:-0}"
    
    # Emit deprecation warning
    echo "WARNING: draw_status_box() is deprecated. Use box_new() + box_render() from Layout Builder instead." >&2
    echo "  Migration: box_id=\$(box_new width title style); box_render \$box_id" >&2
    
    # Source Layout Builder if available
    _layout_builder_source
    
    # Proxy to new system if available
    if command -v box_new >/dev/null 2>&1 && command -v box_render >/dev/null 2>&1; then
        if [[ "$width" == "0" ]]; then
            width=$((COLUMNS - 2))
        fi
        
        local box_id
        box_id=$(box_new "$width" "$title" "$color")
        
        # Add content row
        local row_id
        row_id=$(row_new)
        row_add_cell "$row_id" "$(make_text "$text")"
        box_add_row "$box_id" "$row_id"
        
        box_render "$box_id"
    else
        # Fallback to legacy implementation
        echo "Layout Builder not available, using legacy fallback" >&2
        draw_box "$text" "$title" "$color" "$width"
    fi
}

# Legacy bridge: create_status_line() - Enhanced to use new palette
create_status_line() {
    local status="$1"
    local message="$2"
    local count="${3:-}"
    
    # Source Layout Builder if available for palette
    _layout_builder_source
    
    # Use new palette system if available
    if command -v format_status >/dev/null 2>&1; then
        if [[ -n "$count" ]]; then
            format_status "$status" "$message ($count)"
        else
            format_status "$status" "$message"
        fi
    else
        # Fallback to legacy implementation
        local emoji=""
        local color=""
        
        case "$status" in
            "success")
                emoji="✅"
                color="success"
                ;;
            "error")
                emoji="❌"
                color="error"
                ;;
            "warning")
                emoji="❗"
                color="warning"
                ;;
            "info")
                emoji="ℹ️"
                color="info"
                ;;
            "running")
                emoji="🔄"
                color="accent_cyan"
                ;;
            *)
                emoji="•"
                color="accent_cyan"
                ;;
        esac
        
        local color_code
        color_code=$(get_color "$color")
        local reset_code="\033[0m"
        
        if [[ -n "$count" ]]; then
            echo -e "${color_code}${emoji} ${message} (${count})${reset_code}"
        else
            echo -e "${color_code}${emoji} ${message}${reset_code}"
        fi
    fi
}

# Preserve existing BOX_* glyph variables for drop-in compatibility
# These will be used by legacy functions when Layout Builder is not available
BOX_TOP_LEFT="┌"
BOX_TOP_RIGHT="┐"
BOX_BOTTOM_LEFT="└"
BOX_BOTTOM_RIGHT="┘"
BOX_HORIZONTAL="─"
BOX_VERTICAL="│"
BOX_TOP_LEFT_DOUBLE="╭"
BOX_TOP_RIGHT_DOUBLE="╮"
BOX_BOTTOM_LEFT_DOUBLE="╰"
BOX_BOTTOM_RIGHT_DOUBLE="╯"
BOX_HORIZONTAL_DOUBLE="─"
BOX_VERTICAL_DOUBLE="│"

# Legacy compatibility: STATUS_ICONS (preserved for existing scripts)
declare -Ag STATUS_ICONS=(
    [success]="✅"
    [error]="❌"
    [warning]="❗"
    [info]="ℹ️"
    [running]="🔄"
    [pending]="⏳"
)

# Legacy compatibility: STATUS_COLORS (preserved for existing scripts)
declare -Ag STATUS_COLORS=(
    [success]="success"
    [error]="error"
    [warning]="warning"
    [info]="info"
    [running]="accent_cyan"
    [pending]="accent_magenta"
)

# =============================================================================
# END LEGACY BRIDGE
# =============================================================================
