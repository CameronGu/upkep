# Modular Emoji, Color, and Text Composition System

This guide documents the component-based modular system for creating consistent, maintainable, and extensible terminal output with emojis, colors, and text formatting.

## Overview

The modular system provides a structured approach to terminal output composition using:
- **Centralized semantic maps** for emojis and colors
- **Component abstraction** for all output elements
- **Automatic column width calculation** for perfect table alignment
- **Composable output builder** for consistent formatting

## Core Components

### 1. Semantic Maps

#### EMOJI_MAP
Centralized definition of all emojis with their display properties:
```bash
declare -A EMOJI_MAP=(
    # key = semantic_name, value = "emoji:width:spacing"
    ["success"]="✅:2:1"
    ["error"]="❌:2:1"
    ["warning"]="❗:2:1"
    ["pending"]="⏳:2:1"
    ["running"]="🔄:2:1"
    # ... more emojis
)
```

#### COLOR_MAP
Centralized definition of ANSI color codes:
```bash
declare -A COLOR_MAP=(
    ["success"]="32"    # Green
    ["error"]="31"      # Red
    ["warning"]="33"    # Yellow
    ["info"]="36"       # Cyan
    ["pending"]="35"    # Magenta
    ["running"]="34"    # Blue
    ["bold"]="1"        # Bold
    ["reset"]="0"       # Reset
)
```

### 2. Component System

#### Component Types
- **emoji**: Semantic emoji references (e.g., `emoji:success`)
- **text**: Plain text content (e.g., `text:Hello World`)
- **color**: ANSI color codes (e.g., `color:success`)
- **spacing**: Whitespace padding (e.g., `spacing:3`)

#### Component Builders
```bash
make_emoji_component "success"     # Returns "emoji:success"
make_text_component "Hello World"  # Returns "text:Hello World"
make_color_component "success"     # Returns "color:success"
make_spacing_component "3"         # Returns "spacing:3"
```

#### Component Rendering
```bash
get_component_width "emoji:success"  # Returns display width
render_component "emoji:success"     # Returns rendered string
```

### 3. Line Composition

#### compose_line()
The central function for assembling components into formatted output:
```bash
compose_line 30 \
    "$(make_emoji_component "success")" \
    "$(make_spacing_component "1")" \
    "$(make_text_component "Task completed")"
```

## Table System

### Automatic Column Width Calculation

The system includes functions for creating perfectly aligned tables with automatic column width calculation:

#### Width Calculation Functions
```bash
get_text_width "text"                    # Calculate display width
calculate_column_width "col1" "col2"     # Find maximum width needed
```

#### Table Creation Functions

**Basic Tables:**
```bash
create_table_row 60 "Column1" "Column2" "Column3"
create_header_row 60 "Header1" "Header2" "Header3"
```

**Component-Based Tables:**
```bash
create_component_table_row 60 "Module" "success" "Updated" "45"
create_component_header_row 60 15 12 8 "Package Manager" "Status" "Packages"
```

**Status Tables:**
```bash
create_status_table_row 60 "APT" "2 days ago" "success" "Done" "5 days"
create_aligned_header_row 60 "Module" "Last Run" "Status" "Next Due"
```

### Table Alignment Features

1. **✅ Automatic Width Calculation**: Columns are sized based on actual content
2. **✅ Perfect Alignment**: All columns align regardless of content length
3. **✅ Component Integration**: Emojis and colors use the component system
4. **✅ Dynamic Padding**: Spacing adjusts automatically for consistent alignment

## Box Drawing

### draw_box()
Creates formatted text boxes with optional titles and colors:
```bash
draw_box "Message content" "Optional Title" "success"
```

Features:
- Unicode box drawing characters
- Automatic title centering
- Color support
- Dynamic width calculation

### draw_status_box()
Creates status-specific boxes with semantic colors:
```bash
draw_status_box "System Update" "All packages updated successfully" "success"
```

## Status Reporting

### create_status_line()
Creates formatted status lines with emojis and colors:
```bash
create_status_line "success" "Task completed successfully" "45"
create_status_line "warning" "Some packages were held back" "3"
create_status_line "error" "Failed to update repository"
```

## Utility Functions

### Text Processing
```bash
strip_color_codes "text"     # Remove ANSI color codes
get_emoji "success"          # Get raw emoji character
get_emoji_width "success"    # Get emoji display width
get_emoji_spacing "success"  # Get emoji spacing
get_color_code "success"     # Get ANSI color code
```

### Width Calculation
```bash
get_text_width "text"                    # Calculate display width
calculate_column_width "val1" "val2"     # Find maximum width
get_component_width "emoji:success"      # Get component width
```

## Usage Examples

### Basic Status Line
```bash
echo "$(create_status_line "success" "APT packages updated successfully" "45")"
# Output: ✅ APT packages updated successfully  (45)
```

### Formatted Table
```bash
# Calculate column widths
module_width=$(calculate_column_width "Package Manager" "APT" "Snap")
status_width=$(calculate_column_width "Status" "✅ Updated" "❗ Held")
packages_width=$(calculate_column_width "Packages" "45" "3")

# Create table
create_component_header_row 60 "$module_width" "$status_width" "$packages_width" "Package Manager" "Status" "Packages"
create_component_table_row 60 "APT" "success" "Updated" "45"
create_component_table_row 60 "Snap" "warning" "Held" "3"
```

### Colored Box
```bash
draw_box "All packages updated successfully" "System Update" "success"
```

## Extensibility

### Adding New Emojis
1. Add entry to `EMOJI_MAP`:
```bash
["new_emoji"]="🎯:2:1"
```

2. Use in code:
```bash
make_emoji_component "new_emoji"
```

### Adding New Colors
1. Add entry to `COLOR_MAP`:
```bash
["highlight"]="93"  # Bright yellow
```

2. Use in code:
```bash
make_color_component "highlight"
```

### Creating Custom Components
Extend the component system by adding new component types and corresponding render functions.

## Best Practices

1. **Use Semantic Names**: Always use semantic names (e.g., `success`, `error`) instead of raw emojis
2. **Component Composition**: Build output using components rather than string concatenation
3. **Automatic Width Calculation**: Use the automatic width calculation for tables instead of static widths
4. **Consistent Spacing**: Let the component system handle spacing automatically
5. **Color Integration**: Use semantic color names that match your emoji usage

## Migration Guide

### From Raw Emoji Strings
```bash
# Old way
echo "✅ Task completed"

# New way
echo "$(create_status_line "success" "Task completed")"
```

### From Static Table Widths
```bash
# Old way
printf "%-15s %-12s %-10s\n" "Module" "Status" "Count"

# New way
create_component_header_row 60 15 12 10 "Module" "Status" "Count"
```

### From Manual Color Codes
```bash
# Old way
echo -e "\033[32mSuccess\033[0m"

# New way
echo "$(create_status_line "success" "Success")"
```

## Benefits

1. **✅ Consistency**: All output follows the same formatting rules
2. **✅ Maintainability**: Changes to emojis or colors are centralized
3. **✅ Extensibility**: Easy to add new emojis, colors, or component types
4. **✅ Perfect Alignment**: Tables are automatically aligned regardless of content
5. **✅ Unicode Support**: Proper handling of multi-byte characters
6. **✅ Color Integration**: Seamless integration of colors with emojis and text
7. **✅ Component Reuse**: Components can be mixed and matched for complex layouts 