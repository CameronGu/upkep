# upKep Styling System - Quick Reference

## Essential Functions

### Box Drawing
```bash
draw_box "color" "TITLE" "line1" "line2" "line3"
box_top "color" "TITLE"
box_text_line "color" "text"
box_line "color" "left" "right"
box_bottom "color"
```

### Colors
```bash
get_color "success"    # ✅ Green (bright green in colorblind mode)
get_color "error"      # ❌ Red (pure red in colorblind mode)
get_color "warning"    # ! Yellow (golden yellow in colorblind mode)
get_color "info"       # 💡 Blue (bright blue in colorblind mode)
get_color "accent_cyan"    # Headers
get_color "accent_magenta" # Emphasis
```

### Utilities
```bash
get_box_width          # Dynamic width (60-120 chars)
get_terminal_width     # Current terminal width
get_display_width "text" # Unicode-aware width
fix_emojis "text"      # Replace problematic emojis
is_colorblind_mode     # Check if colorblind mode is active
get_colorblind_indicator "status" # Get text indicator
```

## Status Icons

| Icon | Meaning | Use Case |
|------|---------|----------|
| ✅ | Success | Task completed |
| ❌ | Error | Task failed |
| ! | Warning | Attention needed |
| 🔄 | Progress | Running, in progress |
| ⏳ | Waiting | Pending, queued |
| 📊 | Stats | Performance data |
| 💡 | Info | Suggestion, tip |
| ⏰ | Time | Duration, timing |
| 🔍 | Details | Logs, debug info |

## Common Patterns

### Module Status Report
```bash
draw_box "info" "MODULE STATUS" \
    "✅ Module completed successfully" \
    "⏰ Execution time: ${duration}s" \
    "📊 Performance: Excellent"
```

### Error Display
```bash
draw_box "error" "ERROR SUMMARY" \
    "❌ $error_count errors encountered" \
    "🔍 Check logs for details"
```

### Progress with Spinner
```bash
spinner $! &
local spinner_pid=$!
# ... do work ...
kill $spinner_pid 2>/dev/null
wait $spinner_pid 2>/dev/null
echo -e "\r${SUCCESS_GREEN}✔ Success${RESET}"
```

### Left/Right Alignment
```bash
box_line "info" "✅ Task completed" "2m 30s"
box_line "warning" "!  Warnings" "$warning_count"
```

## Best Practices

### ✅ Do
- Use semantic colors (`success`, `error`, `warning`, `info`)
- Include space after emojis: `"✅ Task"`
- Use consistent icon spacing
- Handle errors gracefully with fallbacks
- Consider accessibility with colorblind mode
- Use text indicators when appropriate

### ❌ Don't
- Hard-code color escape sequences
- Use inconsistent spacing
- Ignore terminal capabilities
- Mix different styling approaches

## Accessibility

### Colorblind Mode
```bash
# Check if colorblind mode is active
if is_colorblind_mode; then
    # Use high-contrast colors and text indicators
    echo "$(get_colorblind_indicator "success") Task completed"
fi

# Create accessible status line
create_accessible_status_line "success" "Task completed" "45"
# Automatically includes text indicators when colorblind mode is enabled
```

### Activation
```bash
# Immediate use
./upkep.sh --colorblind

# Persistent setting
./upkep.sh colorblind on

# Session-only
UPKEP_COLORBLIND=1 ./upkep.sh
```

## Troubleshooting

### Color codes showing as text?
```bash
# Use get_color() instead of hard-coded sequences
box_text_line "success" "✅ Success"  # ✅ Good
printf "\e[32mSuccess\e[0m\n"         # ❌ Bad
```

### Box alignment issues?
```bash
# Check for problematic emojis
fix_emojis "⚠️ ⏭️ ⏱️"  # Returns "! > *"
```

### Spinner not working?
```bash
# Ensure proper PID handling
spinner $! &
local pid=$!
# ... work ...
kill $pid 2>/dev/null
wait $pid 2>/dev/null
```

## Testing

```bash
# Visual check
bash tests/visual_check.sh

# Test styling system
bash tests/test_enhanced_styling.sh

# Test emojis
bash tests/test_all_emojis.sh
```

---

**Source the system:** `source "scripts/modules/core/utils.sh"` 