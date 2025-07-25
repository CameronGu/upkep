# upKep Enhanced Styling System Guide

## Overview

The upKep enhanced styling system provides a comprehensive, terminal-first visual design framework inspired by Taskmaster. This guide explains how to use the styling system effectively in modules and scripts.

## Quick Start

```bash
# Source the styling system
source "scripts/modules/core/utils.sh"

# Basic box with title
draw_box "info" "MODULE STATUS" \
    "✅ Module completed successfully" \
    "⏰ Execution time: 45 seconds" \
    "📊 Performance: Excellent"

# Status line with left/right alignment
box_line "success" "✅ Task completed" "2m 30s"

# Simple text line
box_text_line "warning" "⚠️  Attention required"
```

## Color System

### Available Colors

The system provides semantic colors with automatic fallback support:

```bash
# Primary colors
"primary_bg"    # Deep black background
"primary_fg"    # High-contrast white text
"accent_cyan"   # Headers, section dividers
"accent_magenta" # Progress, emphasis

# Semantic status colors
"success"       # Completed tasks, successful operations
"warning"       # Skipped tasks, pending actions
"error"         # Failed operations, critical issues
"info"          # Informational content, metadata
```

### Color Usage

```bash
# Get color code
local color_code=$(get_color "success")

# Use in printf statements
printf "${color_code}✅ Success${RESET}\n"

# Use in box functions (automatic)
box_text_line "success" "✅ Task completed"
```

### Color Support Detection

The system automatically detects terminal color support:
- **24-bit**: Full color support (modern terminals)
- **256**: Extended color palette
- **8**: Basic ANSI colors
- **none**: No color support (fallback to plain text)

## Box Drawing System

### Basic Box Functions

```bash
# Draw a complete box with title and content
draw_box "color" "TITLE" "line1" "line2" "line3"

# Individual box components
box_top "color" "TITLE"           # Top border with centered title
box_text_line "color" "text"      # Single line of text
box_line "color" "left" "right"   # Left/right aligned text
box_bottom "color"                # Bottom border
```

### Dynamic Width

Boxes automatically adapt to terminal width:
- **Minimum**: 60 characters
- **Preferred**: 80 characters  
- **Maximum**: 120 characters

```bash
# Get current box width
local width=$(get_box_width)

# Get terminal width
local term_width=$(get_terminal_width)
```

### Alignment and Padding

The system handles alignment automatically:

```bash
# Centered title (automatic in box_top)
box_top "info" "MODULE STATUS"

# Left-aligned text (automatic in box_text_line)
box_text_line "info" "✅ Task completed"

# Left/right alignment (automatic in box_line)
box_line "info" "✅ Task completed" "2m 30s"
```

## Emoji and Unicode Handling

### Automatic Emoji Replacement

The system automatically replaces problematic composite emojis with ASCII alternatives:

| Original | Replacement | Use Case |
|----------|-------------|----------|
| ⚠️ | ! | Warnings, attention |
| ⏭️ | > | Skip/next actions |
| ⏱️ | * | Timing information |
| 🗑️ | X | Cleanup, deletion |
| 🖥️ | @ | System operations |
| ⏸️ | \| | Pause, suspend |

### Unicode-Aware Width Calculation

```bash
# Calculate display width (accounts for emojis, CJK chars, etc.)
local width=$(get_display_width "✅ Task completed")

# Strip color codes for width calculation
local stripped=$(strip_color_codes "$colored_text")
local width=$(get_display_width "$stripped")
```

## Status Icons and Indicators

### Recommended Icon Set

```bash
# Success/Completion
"✅" - Task completed successfully
"🎯" - Action required, target reached

# Failure/Error  
"❌" - Task failed to complete
"💥" - Critical error

# Warning/Attention
"!" - Warning (ASCII replacement for ⚠️)
"⚠️" - Attention required (if supported)

# Progress/Status
"🔄" - Task is running, in progress
"⏳" - Task is waiting, pending
"⏸️" - Task is paused, suspended

# Information
"📊" - Statistics, performance data
"💡" - Suggestion, tip
"📋" - New task, unconfigured
"🔧" - Configuration, settings

# Actions
">" - Skip/next (ASCII replacement for ⏭️)
"🗑️" - Cleanup, deletion
"🖥️" - System operation

# Timing
"*" - Timer (ASCII replacement for ⏱️)
"⏰" - Time information
"📅" - Schedule, calendar
```

### Icon Usage Guidelines

```bash
# Use consistent spacing
box_text_line "success" "✅ Task completed successfully"
box_text_line "error" "❌ Task failed to complete"
box_text_line "warning" "!  Task needs attention"

# Combine with status colors
box_text_line "success" "✅ 12 packages updated"
box_text_line "info" "📊 Performance: +23s vs average"
```

## Progress Indicators

### Enhanced Spinner

```bash
# Start spinner
spinner $! &
local spinner_pid=$!

# Do work...
sleep 5

# Stop spinner and show result
kill $spinner_pid 2>/dev/null
wait $spinner_pid 2>/dev/null
echo -e "\r${SUCCESS_GREEN}✔ Success${RESET}"
```

### Progress Bar (Basic)

```bash
# Simple progress indicator
echo -n "Progress: ["
for i in {1..10}; do
    echo -n "█"
    sleep 0.1
done
echo "] Complete"
```

## Module Integration Examples

### Basic Module Status

```bash
#!/bin/bash
source "scripts/modules/core/utils.sh"

# Module header
box_top "accent_cyan" "APT UPDATE MODULE"
echo

# Status display
if [[ $exit_code -eq 0 ]]; then
    box_text_line "success" "✅ APT update completed successfully"
    box_text_line "info" "📊 Updated $package_count packages"
    box_text_line "info" "⏰ Execution time: ${duration}s"
else
    box_text_line "error" "❌ APT update failed"
    box_text_line "info" "🔍 Check logs for details"
fi

box_bottom "accent_cyan"
```

### Detailed Module Report

```bash
#!/bin/bash
source "scripts/modules/core/utils.sh"

# Module execution
start_time=$(date +%s)
# ... module logic ...
end_time=$(date +%s)
duration=$((end_time - start_time))

# Generate report
draw_box "info" "MODULE EXECUTION REPORT" \
    "✅ Module: $module_name" \
    "⏰ Duration: ${duration}s" \
    "📊 Status: $status" \
    "🔍 Logs: $log_file"

# Performance context
if [[ $duration -gt $average_time ]]; then
    box_text_line "warning" "!  Slower than average (+${diff}s)"
else
    box_text_line "success" "✅ Faster than average (-${diff}s)"
fi
```

### Error Handling

```bash
#!/bin/bash
source "scripts/modules/core/utils.sh"

# Error display
if [[ $error_count -gt 0 ]]; then
    draw_box "error" "ERROR SUMMARY" \
        "❌ $error_count errors encountered" \
        "🔍 Check logs for details" \
        "💡 Run with --verbose for more info"
fi

# Warning display
if [[ $warning_count -gt 0 ]]; then
    draw_box "warning" "WARNING SUMMARY" \
        "!  $warning_count warnings" \
        "📋 Review configuration" \
        "🔄 Some operations may be incomplete"
fi
```

## Best Practices

### 1. Consistent Color Usage

```bash
# ✅ Good - Use semantic colors
box_text_line "success" "✅ Task completed"
box_text_line "error" "❌ Task failed"
box_text_line "warning" "!  Attention needed"

# ❌ Avoid - Hard-coded colors
printf "\e[32m✅ Task completed\e[0m\n"
```

### 2. Proper Icon Spacing

```bash
# ✅ Good - Consistent spacing
box_text_line "info" "📊 Performance: Excellent"
box_text_line "info" "💡 Tip: Use --verbose for details"

# ❌ Avoid - Inconsistent spacing
box_text_line "info" "📊Performance: Excellent"
box_text_line "info" "💡Tip: Use --verbose for details"
```

### 3. Dynamic Content

```bash
# ✅ Good - Adapt to content
local status_icon="✅"
local status_color="success"
if [[ $exit_code -ne 0 ]]; then
    status_icon="❌"
    status_color="error"
fi
box_text_line "$status_color" "$status_icon Task $task_name"

# ❌ Avoid - Static content
box_text_line "success" "✅ Task completed"  # Always shows success
```

### 4. Error Handling

```bash
# ✅ Good - Graceful fallbacks
if [[ -n "$TERM" ]] && [[ "$TERM" != "dumb" ]]; then
    # Use enhanced styling
    draw_box "info" "STATUS" "✅ Success"
else
    # Fallback to plain text
    echo "STATUS: Success"
fi
```

## Testing and Validation

### Visual Testing

```bash
# Run visual check
bash tests/visual_check.sh

# Test specific components
bash tests/test_enhanced_styling.sh
```

### Emoji Testing

```bash
# Test emoji display width
bash tests/test_all_emojis.sh

# Test Unicode handling
bash tests/test_unicode_width.sh
```

### Box Drawing Demo

```bash
# Interactive box drawing demonstration
bash tests/box_drawing_demo.sh
```

## Troubleshooting

### Common Issues

1. **Color codes showing as text**
   - Ensure `get_color()` is used correctly
   - Check terminal color support
   - Use `printf "%b"` for escape sequences

2. **Box alignment issues**
   - Check for problematic emojis
   - Verify Unicode width calculation
   - Use `fix_emojis()` function

3. **Spinner not working**
   - Check cursor control support
   - Ensure proper PID handling
   - Verify terminal capabilities

### Debug Functions

```bash
# Test color support
detect_color_support

# Test terminal width
get_terminal_width

# Test display width
get_display_width "test string"

# Test emoji replacement
fix_emojis "⚠️ test ⏭️"
```

## Migration Guide

### From Plain Text

```bash
# Old way
echo "Status: Success"

# New way
box_text_line "success" "✅ Status: Success"
```

### From Basic Boxes

```bash
# Old way
echo "╭─ STATUS ─╮"
echo "│ Success  │"
echo "╰─────────╯"

# New way
draw_box "info" "STATUS" "✅ Success"
```

### From Hard-coded Colors

```bash
# Old way
printf "\e[32mSuccess\e[0m\n"

# New way
box_text_line "success" "✅ Success"
```

## Performance Considerations

- **Color detection**: Cached per session
- **Width calculation**: Optimized for common cases
- **Emoji replacement**: Minimal overhead
- **Box drawing**: Efficient string operations

## Future Enhancements

- **Custom themes**: User-configurable color schemes
- **Animation support**: More sophisticated progress indicators
- **Accessibility**: High-contrast and colorblind-friendly modes
- **Internationalization**: RTL language support

---

For more information, see:
- [Design Specification](DESIGN.md)
- [Box Drawing Explanation](BOX_DRAWING_EXPLANATION.md)
- [Visual Check Script](../tests/visual_check.sh) 