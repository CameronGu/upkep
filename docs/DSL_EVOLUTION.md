# Layout Builder DSL Evolution

## Overview

The upKep Layout Builder has evolved from a complex, procedural approach to a simple, declarative DSL (Domain Specific Language) that makes creating rich terminal layouts much easier and more intuitive.

## The Problem

Originally, creating rich layouts required multiple function calls and complex parameter management:

```bash
# Old procedural approach
box_data=$(box_new 50 "System Status" "info")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text 'System is operational')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
```

This was:
- ❌ Verbose and repetitive
- ❌ Hard to read and understand
- ❌ Error-prone with complex layouts
- ❌ Difficult to maintain and modify

## The Solution: Simplified DSL

We created a set of simple, intuitive functions that handle common layout patterns:

```bash
# New DSL approach
create_success_box "System Status" "All systems operational"
```

This is:
- ✅ Simple and readable
- ✅ Self-documenting
- ✅ Consistent and predictable
- ✅ Easy to maintain and modify

## Available DSL Functions

### Basic Boxes
```bash
create_quick_box "Title" "Content" "style" "width"
create_colored_box "Title" "Content" "color" "style" "width"
```

### Specialized Boxes
```bash
create_success_box "Title" "Message" "width"
create_warning_box "Title" "Message" "width"
create_error_box "Title" "Message" "width"
create_info_box "Title" "Message" "width"
```

### Tables
```bash
create_quick_table "Title" "width" "Header1" "Header2" "Header3"
create_comparison_table "Title" "width" "Label1" "Value1" "Label2" "Value2"
```

### Status and Progress
```bash
create_status_box "Title" "Emoji" "Message" "Color" "Style" "Width"
create_progress_box "Title" "Emoji" "Message" "Progress" "Width"
```

### Dashboards
```bash
create_dashboard_box "Title" "Width" "Info1" "Info2" "Info3"
```

## HTML-like Syntax Support

We also implemented HTML-like syntax for composite cells with mixed content:

```bash
# HTML-like syntax for mixed content
make_html 'Normal text <color=success>success text</color> normal again'
make_html '<emoji=success> Success message'
make_html '<color=warning>⚠️ Warning: <color=error>Critical error</color> detected'
```

### Available HTML Tags
- `<color=key>text</color>` - Colored text
- `<emoji=key>` - Semantic emoji
- `<reset>` - Reset color immediately

### Color Keys
- `success` - Green
- `error` - Red  
- `warning` - Yellow
- `info` - Cyan
- `pending` - Magenta
- `running` - Cyan

### Emoji Keys
- `success` - ✅
- `error` - ❌
- `warning` - ⚠️
- `running` - 🔄
- `pending` - ⏳
- `info` - ℹ️

## Real-world Examples

### Before (Procedural)
```bash
# Create a status report
box_data=$(box_new 60 "System Status Report" "major")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=success> <color=success>APT: 12 packages updated</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=warning> <color=warning>Snap: 3 packages held back</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
```

### After (DSL)
```bash
# Create a status report
create_success_box "APT Update" "12 packages updated successfully"
create_warning_box "Snap Update" "3 packages held back"
```

### Complex Dashboard Before
```bash
# Create dashboard
box_data=$(box_new 70 "System Dashboard" "major")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text '🖥️ System: Ubuntu 22.04 LTS')")
row_data=$(row_add_cell "$row_data" "$(make_text '💾 Disk: 89.4GB free')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text '📊 Total modules: 7')")
row_data=$(row_add_cell "$row_data" "$(make_text '⏰ Last run: 2 hours ago')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
```

### Complex Dashboard After
```bash
# Create dashboard
create_dashboard_box "System Dashboard" 70 "🖥️ System: Ubuntu 22.04 LTS" "💾 Disk: 89.4GB free" "📊 Total modules: 7" "⏰ Last run: 2 hours ago"
```

## Benefits

### For Developers
- **Simplicity**: One function call instead of 5-10
- **Readability**: Self-documenting code
- **Consistency**: Standardized layouts across modules
- **Maintainability**: Easy to modify and extend

### For Users
- **Better UX**: Consistent visual language
- **Rich Information**: Semantic colors and emojis
- **Professional Appearance**: Beautiful, polished layouts
- **Accessibility**: Colorblind-friendly palettes

### For the Project
- **Reduced Complexity**: Less code to maintain
- **Faster Development**: Quick layout creation
- **Better Testing**: Simpler test cases
- **Documentation**: Self-documenting APIs

## Migration Path

### For Existing Code
The old procedural functions are still available for backward compatibility:

```bash
# Old functions still work
box_new width title style
row_new
row_add_cell row_data cell_token
box_add_row box_data row_data
box_render box_data
```

### For New Code
Use the new DSL functions:

```bash
# New DSL functions
create_success_box "Title" "Message"
create_warning_box "Title" "Message"
create_error_box "Title" "Message"
create_dashboard_box "Title" "Info1" "Info2" "Info3"
```

## Future Enhancements

### Planned Features
- **Template System**: Reusable layout templates
- **Dynamic Content**: Variable substitution in templates
- **Conditional Rendering**: Show/hide based on conditions
- **Animation Support**: Animated progress indicators
- **Theme System**: Customizable color schemes

### Advanced DSL
```bash
# Future template syntax (conceptual)
render_template "status_report" {
    "apt_status": "success",
    "apt_count": 12,
    "snap_status": "warning", 
    "snap_count": 3
}
```

## Conclusion

The DSL evolution has transformed the Layout Builder from a complex, procedural system into a simple, declarative one that makes creating beautiful terminal layouts as easy as writing a single function call. This approach provides the best balance of simplicity, power, and maintainability while preserving backward compatibility for existing code.

The new DSL makes upKep's visual output more professional, consistent, and user-friendly while significantly reducing the complexity of creating rich layouts in shell scripts. 