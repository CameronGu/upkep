# Advanced Layout Features Guide

This guide covers how to create complex layouts with multi-line content, columns, and row dividers using the upKep Layout Builder.

## Overview

The Layout Builder supports several advanced features:
- **Multi-line content**: Multiple rows in a single box
- **Multi-column layouts**: Tables with headers and data
- **Row dividers**: Visual separators between sections
- **Mixed content**: Text, emojis, colors, and HTML-like syntax
- **Complex layouts**: Combining all features

## Core Concepts

### Box Structure
```
┌─────────────────Title─────────────────┐
│Row 1: Content                        │
│Row 2: More content                   │
│Row 3: Even more content              │
└───────────────────────────────────────┘
```

### Multi-Column Structure
```
┌─────────────────Title─────────────────┐
│Col1    Col2    Col3    Col4           │
│Data1   Data2   Data3   Data4          │
│Data5   Data6   Data7   Data8          │
└───────────────────────────────────────┘
```

### Row Dividers
```
┌─────────────────Title─────────────────┐
│Section 1                             │
├───────────────────────────────────────┤
│Section 2                             │
├───────────────────────────────────────┤
│Section 3                             │
└───────────────────────────────────────┘
```

## Manual Approach (Using Box Builder Directly)

### 1. Multi-line Content

```bash
# Create a box with multiple rows
box_data=$(box_new 60 "Multi-line Content" "info")

# Add first row
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "First line of content")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add second row
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Second line of content")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add third row
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Third line of content")")
box_data=$(box_add_row "$box_data" "$row_data")

# Render the box
box_render "$box_data"
```

### 2. Multi-column Layout

```bash
# Create a table with headers
box_data=$(box_new 80 "Multi-column Layout" "info")

# Add header row
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Name")")
row_data=$(row_add_cell "$row_data" "$(make_text "Status")")
row_data=$(row_add_cell "$row_data" "$(make_text "Version")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add data row 1
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package A")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Installed</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "1.2.3")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add data row 2
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package B")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=warning>⚠️ Pending</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "2.1.0")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
```

### 3. Row Dividers

```bash
# Create a box with dividers
box_data=$(box_new 70 "Row Dividers Example" "major")

# Add header
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Section")")
row_data=$(row_add_cell "$row_data" "$(make_text "Details")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Add content after divider
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "System Info")")
row_data=$(row_add_cell "$row_data" "$(make_text "Ubuntu 22.04 LTS")")
box_data=$(box_add_row "$box_data" "$row_data")

# Add another divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Add more content
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Kernel")")
row_data=$(row_add_cell "$row_data" "$(make_text "5.15.0-generic")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
```

## DSL Approach (Using Advanced Functions)

### 1. Multi-line Box

```bash
# Simple multi-line box
create_multiline_box --title="System Information" --width="60" \
    "Operating System: Ubuntu 22.04 LTS" \
    "Kernel Version: 5.15.0-generic" \
    "Architecture: x86_64" \
    "Uptime: 3 days, 7 hours"
```

### 2. Advanced Table

```bash
# Table with headers, data, and dividers
create_table --title="Package Status" --width="80" --style="info" \
    --headers "Package" "Status" "Version" "Last Updated" \
    --data "Package A|<color=success>✅ Installed</color>|1.2.3|2 hours ago" \
    --data "Package B|<color=warning>⚠️ Pending</color>|2.1.0|1 day ago" \
    --data "Package C|<color=error>❌ Failed</color>|0.9.5|3 days ago" \
    --divider \
    --data "Total|3 packages|Mixed|Various"
```

### 3. Status Report

```bash
# Status report with sections and dividers
create_status_report --title="System Status Report" --width="85" --style="major" \
    --section="CPU|4 cores, 25% usage, normal operation" \
    --section="Memory|8GB total, 85% used, high usage warning" \
    --section="Disk|500GB, 45% used, good condition" \
    --section="Network|Connected, 100Mbps, stable"
```

### 4. Comparison Table

```bash
# Simple comparison table
create_comparison_table --title="System Comparison" --width="70" --style="info" \
    "OS" "Ubuntu 22.04" \
    "Kernel" "5.15.0" \
    "Architecture" "x86_64" \
    "Uptime" "3 days"
```

## Content Types

### Text Content
```bash
make_text "Plain text content"
```

### Emoji Content
```bash
make_emoji "success"    # ✅
make_emoji "warning"    # ⚠️
make_emoji "error"      # ❌
make_emoji "running"    # 🔄
make_emoji "info"       # ℹ️
```

### HTML-like Content
```bash
make_html '<color=success>Green text</color>'
make_html '<color=warning>Yellow text</color>'
make_html '<color=error>Red text</color>'
make_html '<color=info>Cyan text</color>'
make_html '<emoji=success> With emoji</emoji>'
make_html '<color=success>✅ Success message</color>'
```

### Mixed Content
```bash
# Combine different content types in a single cell
make_html '<color=success>✅ <color=warning>Mixed</color> content</color>'
```

## Box Styles

### Available Styles
- `info` - Standard info box (┌─┐)
- `success` - Success box (┌─┐ with green color)
- `warning` - Warning box (┌─┐ with yellow color)
- `error` - Error box (┌─┐ with red color)
- `major` - Major emphasis (╭─╮)
- `emphasis` - Heavy emphasis (█─█)

### Style Examples
```bash
# Different box styles
box_new 50 "Info Box" "info"
box_new 50 "Success Box" "success"
box_new 50 "Warning Box" "warning"
box_new 50 "Error Box" "error"
box_new 50 "Major Box" "major"
box_new 50 "Emphasis Box" "emphasis"
```

## Advanced Patterns

### 1. Complex Dashboard
```bash
# Create a comprehensive dashboard
create_status_report --title="System Dashboard" --width="90" --style="major" \
    --section="System Info|<emoji=info> Ubuntu 22.04 LTS" \
    --section="Performance|<emoji=stats> CPU: 25%, Memory: 85%" \
    --section="Updates|<emoji=package> 12 packages available" \
    --section="Security|<emoji=success> All systems secure"
```

### 2. Installation Log
```bash
# Multi-line installation log with colors
create_multiline_box --title="Installation Log" --width="75" --style="info" \
    "Starting installation process..." \
    "<color=success>✅ Dependencies resolved</color>" \
    "<color=info>📦 Downloading packages...</color>" \
    "<color=warning>⚠️ 3 packages held back</color>" \
    "<color=success>✅ Installation completed</color>"
```

### 3. Detailed Report
```bash
# Complex table with multiple sections
create_table --title="Detailed System Report" --width="90" --style="emphasis" \
    --headers "Component" "Status" "Details" "Actions" \
    --data "System|<color=success>✅ Operational</color>|All systems running|Monitor" \
    --data "Updates|<color=warning>⚠️ Pending</color>|12 packages available|Install" \
    --divider \
    --data "Security|<color=success>✅ Secure</color>|No vulnerabilities|Continue" \
    --data "Backup|<color=error>❌ Failed</color>|Last backup: 5 days ago|Fix"
```

## Best Practices

### 1. Width Considerations
- Choose appropriate widths for your content
- Consider terminal size and readability
- Use consistent widths across related boxes

### 2. Content Organization
- Use headers to organize information
- Use dividers to separate sections
- Group related information together

### 3. Color Usage
- Use colors consistently (success=green, warning=yellow, error=red)
- Don't overuse colors - they should enhance readability
- Consider colorblind users when choosing colors

### 4. Emoji Usage
- Use semantic emoji keys for consistency
- Emojis should add value, not clutter
- Consider terminal emoji support

### 5. Performance
- For complex layouts, use the DSL functions
- For simple layouts, manual approach is fine
- Cache box data when reusing layouts

## Troubleshooting

### Common Issues

1. **Content not displaying correctly**
   - Check that content is properly quoted
   - Verify HTML syntax is correct
   - Ensure emoji keys are valid

2. **Box width issues**
   - Content may be truncated if box is too narrow
   - Use appropriate width for your content
   - Test with different terminal sizes

3. **Color not showing**
   - Verify terminal supports colors
   - Check that color codes are correct
   - Ensure HTML syntax is properly formatted

4. **Row dividers not working**
   - Use "divider" as exact string
   - Don't add cells to divider rows
   - Check box style supports dividers

### Debug Tips

1. **Test individual components**
   ```bash
   # Test a single cell
   make_text "Test content"
   make_html "<color=success>Test</color>"
   ```

2. **Test box rendering**
   ```bash
   # Simple test box
   box_data=$(box_new 50 "Test" "info")
   row_data=$(row_new)
   row_data=$(row_add_cell "$row_data" "$(make_text "Test")")
   box_data=$(box_add_row "$box_data" "$row_data")
   box_render "$box_data"
   ```

3. **Check function availability**
   ```bash
   # Verify functions are loaded
   type create_multiline_box
   type create_table
   type create_status_report
   ```

## Examples

See the test files for complete working examples:
- `tests/test_advanced_layouts.sh` - Manual approach examples
- `tests/test_advanced_dsl.sh` - DSL approach examples
- `tests/test_comprehensive_dsl.sh` - Complete DSL examples

## Summary

The Layout Builder provides powerful tools for creating complex terminal layouts:

✅ **Multi-line content** - Multiple rows in a single box
✅ **Multi-column layouts** - Tables with headers and data
✅ **Row dividers** - Visual separators between sections
✅ **Mixed content** - Text, emojis, colors, and HTML-like syntax
✅ **Complex layouts** - Combining all features
✅ **DSL functions** - High-level functions for common patterns
✅ **Manual control** - Direct access to box builder primitives

Choose the approach that best fits your needs - DSL for common patterns, manual for custom layouts. 