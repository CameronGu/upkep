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
get_color "success"    # ✅ Green
get_color "error"      # ❌ Red  
get_color "warning"    # ! Yellow
get_color "info"       # 💡 Blue
get_color "accent_cyan"    # Headers
get_color "accent_magenta" # Emphasis
```

### Utilities
```bash
get_box_width          # Dynamic width (60-120 chars)
get_terminal_width     # Current terminal width
get_display_width "text" # Unicode-aware width
fix_emojis "text"      # Replace problematic emojis
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

### ❌ Don't
- Hard-code color escape sequences
- Use inconsistent spacing
- Ignore terminal capabilities
- Mix different styling approaches

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