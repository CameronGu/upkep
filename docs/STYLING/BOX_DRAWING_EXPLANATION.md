# Box Drawing System Explanation

This document explains how the enhanced box drawing system works in `scripts/modules/core/utils.sh`, specifically focusing on color selection and spacing/padding for proper alignment.

## Overview

The box drawing system creates visually appealing bordered boxes in the terminal using Unicode box-drawing characters and dynamic sizing. It supports:
- Dynamic width based on terminal size
- Color-coded borders and content
- Proper text alignment and padding
- Hierarchical display with nested elements

## Key Components

### 1. Dynamic Width Calculation

```bash
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
```

**How it works:**
- Detects actual terminal width using `tput cols`
- Constrains box width between 60-120 characters
- Uses preferred width of 80 characters for most terminals
- Ensures boxes fit properly on different screen sizes

### 2. Color Selection System

```bash
# Get color code with fallback support
get_color() {
    local color_name="$1"
    local color_support=$(detect_color_support)
    
    case "$color_support" in
        "24bit")
            case "$color_name" in
                "primary_bg") echo "$PRIMARY_BG" ;;
                "primary_fg") echo "$PRIMARY_FG" ;;
                "accent_cyan") echo "$ACCENT_CYAN" ;;
                "accent_magenta") echo "$ACCENT_MAGENTA" ;;
                "success") echo "$SUCCESS_GREEN" ;;
                "warning") echo "$WARNING_YELLOW" ;;
                "error") echo "$ERROR_RED" ;;
                "info") echo "$INFO_BLUE" ;;
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
```

**How it works:**
- Detects terminal color support (24-bit, 256-color, 8-color, or none)
- Maps semantic color names to appropriate escape codes
- Provides fallback for terminals with limited color support
- Returns empty string for no-color terminals

### 3. Character Repetition Utility

```bash
# Enhanced character repetition with Unicode support
repeat_char() {
    local char="$1" count="$2"
    local i
    for ((i=0; i<count; i++)); do
        printf "%s" "$char"
    done
}
```

**How it works:**
- Repeats a character a specified number of times
- Used for creating horizontal borders and padding
- Supports Unicode characters like `─` for borders

## Box Drawing Functions

### 1. Box Top (Title Bar)

```bash
box_top() {
    local color="$1" title=" $2 "
    local box_width=$(get_box_width)
    local title_len=${#title}
    local left=$(( (box_width - title_len) / 2 ))
    local right=$(( box_width - left - title_len ))
    
    local color_code=$(get_color "$color")
    printf "${color_code}╭%s%s%s╮${RESET}\n" \
        "$(repeat_char '─' "$left")" \
        "$title" \
        "$(repeat_char '─' "$right")"
}
```

**How it works:**
1. **Title Preparation**: Adds spaces around the title (`" $2 "`)
2. **Width Calculation**: Gets dynamic box width
3. **Centering Logic**: 
   - `title_len=${#title}` - Gets actual character length
   - `left=$(( (box_width - title_len) / 2 ))` - Calculates left padding
   - `right=$(( box_width - left - title_len ))` - Calculates right padding
4. **Border Construction**: Creates `╭─title─╮` pattern
5. **Color Application**: Applies color to borders, not title text

**Example:**
```bash
box_top "success" "APT UPDATE COMPLETE"
# Creates: ╭───────────── APT UPDATE COMPLETE ──────────────╮
```

### 2. Box Text Line (Content)

```bash
box_text_line() { 
    local color="$1" text="$2"
    local box_width=$(get_box_width)
    local color_code=$(get_color "$color")
    printf "${color_code}│ ${PRIMARY_FG}%-*s${RESET}${color_code} │${RESET}\n" \
        $((box_width-2)) "$text"
}
```

**How it works:**
1. **Padding Calculation**: `$((box_width-2))` accounts for `│ ` and ` │` (2 characters each side)
2. **Text Formatting**: Uses `%-*s` for left-aligned text with dynamic width
3. **Color Separation**: Borders use box color, text uses primary foreground color
4. **Structure**: `│ text with padding │`

**Example:**
```bash
box_text_line "success" "✅ 12 packages updated successfully"
# Creates: │ ✅ 12 packages updated successfully                    │
```

### 3. Box Line (Left/Right Alignment)

```bash
box_line() {
    local color="$1" left="$2" right="$3"
    local box_width=$(get_box_width)
    local color_code=$(get_color "$color")
    local inner=$((box_width - 2))
    local pad=$(( inner - ${#left} - ${#right} ))
    (( pad < 0 )) && pad=0
    printf "${color_code}│ ${PRIMARY_FG}%s%*s%s${RESET}${color_code} │${RESET}\n" \
        "$left" "$pad" "" "$right"
}
```

**How it works:**
1. **Inner Width**: `inner=$((box_width - 2))` - Available space between borders
2. **Padding Calculation**: `pad=$(( inner - ${#left} - ${#right} ))` - Space between left and right text
3. **Safety Check**: `(( pad < 0 )) && pad=0` - Prevents negative padding
4. **Format String**: `%s%*s%s` - left text + padding + right text
5. **Structure**: `│ left_text    right_text │`

**Example:**
```bash
box_line "success" "APT" "✅ Done"
# Creates: │ APT                                                       ✅ Done │
```

### 4. Box Bottom

```bash
box_bottom() { 
    local color="$1"
    local box_width=$(get_box_width)
    local color_code=$(get_color "$color")
    printf "${color_code}╰%s╯${RESET}\n" "$(repeat_char '─' "$box_width")"
}
```

**How it works:**
1. **Simple Construction**: Creates bottom border with `╰─╯` pattern
2. **Full Width**: Uses entire box width for horizontal line
3. **Color Application**: Applies same color as other borders

### 5. Complete Box Drawing

```bash
draw_box() { 
    local color="$1" title="$2"
    shift 2
    box_top "$color" "$title"
    for line in "$@"; do 
        box_text_line "$color" "$line"
    done
    box_bottom "$color"
}
```

**How it works:**
1. **Title**: Creates top border with centered title
2. **Content Lines**: Processes each remaining argument as a content line
3. **Bottom**: Adds closing border
4. **Consistent Color**: Uses same color throughout

## Spacing and Alignment Rules

### 1. Width Constraints
- **Minimum**: 60 characters (ensures readability)
- **Maximum**: 120 characters (prevents overflow)
- **Preferred**: 80 characters (optimal for most terminals)

### 2. Padding Calculations
- **Box Borders**: 2 characters total (`│ ` and ` │`)
- **Available Content Width**: `box_width - 2`
- **Title Centering**: Divides remaining space equally
- **Text Alignment**: Left-aligned with full-width padding

### 3. Color Application
- **Borders**: Use semantic color (success, warning, error, etc.)
- **Text**: Use primary foreground color for readability
- **Fallback**: Graceful degradation for limited color support

## Example Usage

```bash
# Simple success box
draw_box "success" "OPERATION COMPLETE" \
    "✅ Task completed successfully" \
    "⏱️  Execution time: 45 seconds" \
    "📊 12 items processed"

# Complex table-like structure
box_top "accent_cyan" "SYSTEM STATUS"
box_line "accent_cyan" "Module" "Status" "Last Run"
box_line "accent_cyan" "─────" "──────" "────────"
box_line "accent_cyan" "APT" "✅ Done" "2 days ago"
box_line "accent_cyan" "Snap" "⚠️ Due" "Now"
box_bottom "accent_cyan"
```

## Key Design Principles

1. **Responsive**: Adapts to terminal size
2. **Accessible**: Works with limited color support
3. **Consistent**: Uniform spacing and alignment
4. **Semantic**: Color coding matches meaning
5. **Readable**: High contrast and proper spacing

This system provides a foundation for creating professional-looking terminal interfaces while maintaining compatibility across different terminal types and configurations. 