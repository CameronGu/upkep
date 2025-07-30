#!/bin/bash
# upKep Layout Builder - Centralized Palette System
# Provides semantic color and emoji maps with colorblind support
# Based on layout_builder_spec.md v1.2

# Default emoji palette with semantic mappings
declare -Ag EMOJI_MAP_DEFAULT=(
    [success]="✅"
    [error]="❌"
    [warning]="❗"
    [running]="🔄"
    [pending]="⏳"
    [info]="❓"
    [skip]="↪️"
    [new]="🆕"
    [timing]="⏰"
    [stats]="📊"
    [suggestion]="💡"
    [action]="⚡"
    [config]="⚙️"
    [package]="📦"
    [cleanup]="🧹"
    [details]="📋"
)

# Colorblind-friendly emoji palette (simplified symbols)
declare -Ag EMOJI_MAP_CB=(
    [success]="✔"
    [error]="✖"
    [warning]="!"
    [running]="~"
    [pending]="…"
    [info]="i"
    [skip]=">"
    [new]="+"
    [timing]="t"
    [stats]="s"
    [suggestion]="?"
    [action]="*"
    [config]="c"
    [package]="p"
    [cleanup]="x"
    [details]="d"
)

# Default color palette with ANSI codes (WCAG-AA compliant)
declare -Ag COLOR_MAP_DEFAULT=(
    [success]="32"      # Green
    [error]="31"        # Red
    [warning]="33"      # Yellow
    [info]="36"         # Cyan
    [pending]="35"      # Magenta
    [running]="36"      # Cyan
    [skip]="37"         # White
    [new]="32;1"        # Bright Green
    [timing]="34"       # Blue
    [stats]="35"        # Magenta
    [suggestion]="33;1" # Bright Yellow
    [action]="31;1"     # Bright Red
    [config]="36;1"     # Bright Cyan
    [package]="34;1"    # Bright Blue
    [cleanup]="37;1"    # Bright White
    [details]="37"      # White
    [reset]="0"         # Reset
)

# Colorblind-friendly color palette (high contrast, semantic)
declare -Ag COLOR_MAP_CB=(
    [success]="97;1"    # Bright White (bold)
    [error]="31;1"      # Bright Red (bold)
    [warning]="34"      # Blue
    [info]="37"         # White
    [pending]="35"      # Magenta
    [running]="36"      # Cyan
    [skip]="37"         # White
    [new]="97;1"        # Bright White (bold)
    [timing]="34;1"     # Bright Blue (bold)
    [stats]="35;1"      # Bright Magenta (bold)
    [suggestion]="33;1" # Bright Yellow (bold)
    [action]="31;1"     # Bright Red (bold)
    [config]="36;1"     # Bright Cyan (bold)
    [package]="34;1"    # Bright Blue (bold)
    [cleanup]="37;1"    # Bright White (bold)
    [details]="37"      # White
    [reset]="0"         # Reset
)

# Global palette variables (set by choose_palette)
declare -g EMOJI_MAP
declare -g COLOR_MAP

# Choose palette based on environment variable
choose_palette() {
    if [[ "${UPKEP_COLORBLIND:-0}" == "1" ]]; then
        EMOJI_MAP="EMOJI_MAP_CB"
        COLOR_MAP="COLOR_MAP_CB"
    else
        EMOJI_MAP="EMOJI_MAP_DEFAULT"
        COLOR_MAP="COLOR_MAP_DEFAULT"
    fi
}

# Get emoji by semantic key
get_emoji() {
    local key="$1"
    local emoji_map_name="$EMOJI_MAP"
    case "$emoji_map_name" in
        "EMOJI_MAP_DEFAULT")
            echo "${EMOJI_MAP_DEFAULT[$key]:-?}"
            ;;
        "EMOJI_MAP_CB")
            echo "${EMOJI_MAP_CB[$key]:-?}"
            ;;
        *)
            echo "?"
            ;;
    esac
}

# Get color by semantic key
get_color() {
    local key="$1"
    local color_map_name="$COLOR_MAP"
    case "$color_map_name" in
        "COLOR_MAP_DEFAULT")
            echo "${COLOR_MAP_DEFAULT[$key]:-0}"
            ;;
        "COLOR_MAP_CB")
            echo "${COLOR_MAP_CB[$key]:-0}"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Format text with color
format_color() {
    local color_key="$1"
    local text="$2"
    local color_code=$(get_color "$color_key")
    echo -e "\033[${color_code}m${text}\033[0m"
}

# Format status with icon and color
format_status() {
    local status_key="$1"
    local text="$2"
    local emoji=$(get_emoji "$status_key")
    local color_code=$(get_color "$status_key")
    echo -e "\033[${color_code}m${emoji} ${text}\033[0m"
}

# Initialize palette on script load
choose_palette

# Functions are available when script is sourced
# No export needed for sourced scripts 