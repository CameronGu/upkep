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
# EMOJI REPLACEMENT FOR ALIGNMENT FIXES
# =============================================================================

# Strip ANSI color codes for width calculation
strip_color_codes() {
    local text="$1"
    # Remove ANSI escape sequences (color codes, formatting, etc.)
    # This handles both literal escape sequences and actual escape sequences
    echo "$text" | sed -E 's/\\e\[[0-9;]*[a-zA-Z]//g; s/\x1b\[[0-9;]*[a-zA-Z]//g'
}

# Replace problematic emojis with ASCII alternatives
# These emojis are composite (2+ Unicode code points) and render as 4 display columns
# instead of the expected 2, causing alignment issues in boxes
# Using ASCII alternatives ensures perfect alignment
fix_emojis() {
    local text="$1"

    # Replace problematic emojis with ASCII alternatives for perfect alignment
    text="${text//⚠️/!}"       # Warning: composite → ASCII exclamation
    text="${text//⏭️/>}"       # Skip/Next: composite → ASCII greater than
    text="${text//⏱️/*}"       # Timer: composite → ASCII asterisk
    text="${text//🗑️/X}"       # Trash: composite → ASCII X
    text="${text//🖥️/@}"       # Computer: composite → ASCII at symbol
    text="${text//⏸️/|}"       # Pause: composite → ASCII pipe

    echo "$text"
}

# Enhanced text line with proper padding and emoji fixes
box_text_line() {
    local color="$1" text="$2"
    local box_width=$(get_box_width)

    # Fix problematic emojis in the text
    local fixed_text=$(fix_emojis "$text")

    # Calculate display width by stripping color codes first, then calculating width
    local stripped_text=$(strip_color_codes "$fixed_text")
    local text_display_width=$(get_display_width "$stripped_text")
    local available_width=$((box_width - 2))
    local padding_needed=$((available_width - text_display_width))

    local color_code=$(get_color "$color")
    printf "${color_code}│ %s%*s${color_code} │${RESET}\n" \
        "$fixed_text" "$padding_needed" ""
}

# =============================================================================
# ENHANCED BOX DRAWING SYSTEM
# =============================================================================

# Get current box width
BOX_W=$(get_box_width)

# Enhanced box top with dynamic width
box_top() {
    local color="$1" title=" $2 "
    local box_width=$(get_box_width)
    local title_display_width=$(get_display_width "$title")
    local left=$(( (box_width - title_display_width) / 2 ))
    local right=$(( box_width - left - title_display_width ))

    local color_code=$(get_color "$color")
    printf "${color_code}╭%s%s%s╮${RESET}\n" \
        "$(repeat_char '─' "$left")" \
        "$title" \
        "$(repeat_char '─' "$right")"
}

# Enhanced box bottom
box_bottom() {
    local color="$1"
    local box_width=$(get_box_width)
    local color_code=$(get_color "$color")
    printf "${color_code}╰%s╯${RESET}\n" "$(repeat_char '─' "$box_width")"
}

# Enhanced line with left/right alignment
box_line() {
    local color="$1" left="$2" right="$3"
    local box_width=$(get_box_width)
    local color_code=$(get_color "$color")
    local inner=$((box_width - 2))

    # Fix problematic emojis in both left and right text
    local fixed_left=$(fix_emojis "$left")
    local fixed_right=$(fix_emojis "$right")

    # Calculate display width by stripping color codes first
    local stripped_left=$(strip_color_codes "$fixed_left")
    local stripped_right=$(strip_color_codes "$fixed_right")
    local left_display_width=$(get_display_width "$stripped_left")
    local right_display_width=$(get_display_width "$stripped_right")

    local pad=$(( inner - left_display_width - right_display_width ))
    (( pad < 0 )) && pad=0
    printf "${color_code}│ %s%*s%s${color_code} │${RESET}\n" \
        "$fixed_left" "$pad" "" "$fixed_right"
}

# Enhanced box drawing with multiple content lines
draw_box() {
    local color="$1" title="$2"
    shift 2
    box_top "$color" "$title"
    for line in "$@"; do
        box_text_line "$color" "$line"
    done
    box_bottom "$color"
}

# =============================================================================
# ENHANCED SPINNER AND PROGRESS INDICATORS
# =============================================================================

# Enhanced spinner with better visual feedback
spinner() {
    local pid=$1
    local msg="$2"
    local spin="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    local color_code=$(get_color "accent_magenta")

    # Hide cursor
    if command -v tput >/dev/null 2>&1; then
        tput civis 2>/dev/null || true
    fi

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${color_code}%s ${msg}${RESET}" "${spin:$i:1}"
        sleep 0.1
    done
    wait $pid
    local exit_code=$?

    # Show cursor
    if command -v tput >/dev/null 2>&1; then
        tput cnorm 2>/dev/null || true
    fi

    # Show result
    if [[ $exit_code -eq 0 ]]; then
        local success_color=$(get_color "success")
        printf "\r${success_color}✔ ${msg}${RESET}%*s\n" 30 ""
    else
        local error_color=$(get_color "error")
        printf "\r${error_color}✗ ${msg}${RESET}%*s\n" 30 ""
    fi

    return $exit_code
}

# =============================================================================
# LEGACY COMPATIBILITY FUNCTIONS
# =============================================================================

# Legacy draw_summary function (maintained for backward compatibility)
draw_summary() {
    local c="accent_magenta"
    box_top "$c" "SUMMARY"
    if [[ -n $SKIP_NOTE ]]; then
        local warning_color=$(get_color "warning")
        local box_width=$(get_box_width)
        printf "${warning_color}│ %-*s${RESET} │\n" $((box_width-2)) "$SKIP_NOTE"
        printf "├%s┤\n" "$(repeat_char '─' "$box_width")"
    fi
    box_line "$c" "APT"      "$APT_STATUS"
    box_line "$c" "Snap"     "$SNAP_STATUS"
    box_line "$c" "Flatpak"  "$FLATPAK_STATUS"
    box_line "$c" "Cleanup"  "$CLEANUP_STATUS"
    box_bottom "$c"
}
