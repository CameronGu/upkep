# HTML-like Layout Syntax Guide

This guide covers the HTML-like syntax for defining complex layouts in the upKep Layout Builder.

## Overview

The HTML-like layout syntax provides a declarative way to define entire layouts using familiar HTML-like tags. This approach eliminates the need to manually write row data and makes layouts more readable and maintainable.

## Core Syntax

### Basic Structure

```bash
# Define layout as a string with HTML-like tags
layout="
<header>Column1|Column2|Column3</header>
<divider/>
<data>Data1|Data2|Data3</data>
<data>Data4|Data5|Data6</data>
"

# Parse and render the layout
parse_html_layout "$layout" 80 "My Table" "info"
```

### Available Tags

#### `<row>content</row>`
Simple single-cell row with content.

```bash
<row>This is a simple row with text content</row>
<row><color=success>This row has colored content</color></row>
```

#### `<cells>cell1|cell2|cell3</cells>`
Multi-cell row with content separated by `|`.

```bash
<cells>Name|Status|Version</cells>
<cells>Package A|<color=success>✅ Installed</color>|1.2.3</cells>
```

#### `<header>header1|header2|header3</header>`
Header row for tables. Automatically styled as headers.

```bash
<header>Component|Status|Details|Actions</header>
```

#### `<data>data1|data2|data3</data>`
Data row for tables. Can contain HTML-like content.

```bash
<data>System|<color=success>✅ Operational</color>|All systems running|Monitor</data>
<data>Updates|<color=warning>⚠️ Pending</color>|12 packages available|Install</data>
```

#### `<divider/>`
Row divider for visual separation.

```bash
<divider/>
```

#### Comments
Lines starting with `#` are treated as comments and ignored.

```bash
# This is a comment
<header>Column1|Column2</header>
# Another comment
<data>Data1|Data2</data>
```

## Usage Examples

### 1. Simple Multi-line Box

```bash
# Using convenience function
create_html_box "System Information" 60 "info" \
    "Operating System: Ubuntu 22.04 LTS" \
    "Kernel Version: 5.15.0-generic" \
    "Architecture: x86_64" \
    "Uptime: 3 days, 7 hours"

# Using raw layout syntax
layout="
<row>Operating System: Ubuntu 22.04 LTS</row>
<row>Kernel Version: 5.15.0-generic</row>
<row>Architecture: x86_64</row>
<row>Uptime: 3 days, 7 hours</row>
"
parse_html_layout "$layout" 60 "System Information" "info"
```

### 2. Table with Headers and Data

```bash
# Using convenience function
create_html_table "Package Status" 80 "info" \
    "Package|Status|Version|Last Updated" \
    "Package A|<color=success>✅ Installed</color>|1.2.3|2 hours ago" \
    "Package B|<color=warning>⚠️ Pending</color>|2.1.0|1 day ago" \
    "Package C|<color=error>❌ Failed</color>|0.9.5|3 days ago"

# Using raw layout syntax
layout="
<header>Package|Status|Version|Last Updated</header>
<divider/>
<data>Package A|<color=success>✅ Installed</color>|1.2.3|2 hours ago</data>
<data>Package B|<color=warning>⚠️ Pending</color>|2.1.0|1 day ago</data>
<data>Package C|<color=error>❌ Failed</color>|0.9.5|3 days ago</data>
"
parse_html_layout "$layout" 80 "Package Status" "info"
```

### 3. Status Report with Sections

```bash
# Using convenience function
create_html_report "System Status Report" 85 "major" \
    "CPU|4 cores, 25% usage, normal operation" \
    "Memory|8GB total, 85% used, high usage warning" \
    "Disk|500GB, 45% used, good condition" \
    "Network|Connected, 100Mbps, stable"

# Using raw layout syntax
layout="
<row><color=info>CPU</color></row>
<row>4 cores, 25% usage, normal operation</row>
<divider/>
<row><color=info>Memory</color></row>
<row>8GB total, 85% used, high usage warning</row>
<divider/>
<row><color=info>Disk</color></row>
<row>500GB, 45% used, good condition</row>
<divider/>
<row><color=info>Network</color></row>
<row>Connected, 100Mbps, stable</row>
"
parse_html_layout "$layout" 85 "System Status Report" "major"
```

### 4. Comparison Table

```bash
# Using convenience function
create_html_comparison "System Comparison" 70 "info" \
    "OS" "Ubuntu 22.04" \
    "Kernel" "5.15.0" \
    "Architecture" "x86_64" \
    "Uptime" "3 days"

# Using raw layout syntax
layout="
<header>Item|Value</header>
<divider/>
<data>OS|Ubuntu 22.04</data>
<data>Kernel|5.15.0</data>
<data>Architecture|x86_64</data>
<data>Uptime|3 days</data>
"
parse_html_layout "$layout" 70 "System Comparison" "info"
```

### 5. Complex Layout with Mixed Content

```bash
# Complex layout combining multiple row types
complex_layout="
# Complex layout example
<row><color=info>📊 System Dashboard</color></row>
<divider/>
<cells>Component|Status|Details</cells>
<data>CPU|<color=success>✅ Normal</color>|4 cores, 25% usage</data>
<data>Memory|<color=warning>⚠️ High</color>|8GB total, 85% used</data>
<data>Disk|<color=success>✅ Good</color>|500GB, 45% used</data>
<divider/>
<row><color=info>📋 Summary</color></row>
<row>System running normally with some high memory usage</row>
"

parse_html_layout "$complex_layout" 85 "Complex Layout Example" "major"
```

## Content Types

### Plain Text
```bash
<row>Simple text content</row>
<data>Plain text|More text</data>
```

### Colored Text
```bash
<row><color=success>Green text</color></row>
<data>Status|<color=warning>Yellow warning</color></data>
```

### Emojis
```bash
<row><emoji=success> Success message</emoji></row>
<data>Status|<emoji=warning> Warning</emoji></data>
```

### Mixed Content
```bash
<row><color=success>✅ <color=warning>Mixed</color> content</color></row>
<data>System|<color=success>✅ Operational</color>|All systems running</data>
```

## Convenience Functions

### `create_html_box(title, width, style, ...lines)`
Creates a simple multi-line box.

```bash
create_html_box "Title" 60 "info" "Line 1" "Line 2" "Line 3"
```

### `create_html_table(title, width, style, headers, ...data_rows)`
Creates a table with headers and data.

```bash
create_html_table "Title" 80 "info" "Col1|Col2|Col3" "Data1|Data2|Data3" "Data4|Data5|Data6"
```

### `create_html_report(title, width, style, ...sections)`
Creates a status report with sections.

```bash
create_html_report "Title" 80 "major" "Section1|Content1" "Section2|Content2"
```

### `create_html_comparison(title, width, style, ...pairs)`
Creates a comparison table.

```bash
create_html_comparison "Title" 70 "info" "Item1" "Value1" "Item2" "Value2"
```

## Advanced Patterns

### 1. Installation Log
```bash
layout="
<row>Starting installation process...</row>
<row><color=success>✅ Dependencies resolved</color></row>
<row><color=info>📦 Downloading packages...</color></row>
<row><color=warning>⚠️ 3 packages held back</color></row>
<row><color=success>✅ Installation completed</color></row>
"
parse_html_layout "$layout" 75 "Installation Log" "info"
```

### 2. Detailed System Report
```bash
layout="
<header>Component|Status|Details|Actions</header>
<divider/>
<data>System|<color=success>✅ Operational</color>|All systems running|Monitor</data>
<data>Updates|<color=warning>⚠️ Pending</color>|12 packages available|Install</data>
<divider/>
<data>Security|<color=success>✅ Secure</color>|No vulnerabilities|Continue</data>
<data>Backup|<color=error>❌ Failed</color>|Last backup: 5 days ago|Fix</data>
<divider/>
<data>Summary|<color=info>📊 Mixed</color>|Mostly good, some issues|Review</data>
"
parse_html_layout "$layout" 90 "Detailed System Report" "emphasis"
```

### 3. Dashboard with Multiple Sections
```bash
layout="
<row><color=info>📊 System Dashboard</color></row>
<divider/>
<cells>Metric|Value|Status</cells>
<data>CPU Usage|25%|<color=success>✅ Normal</color></data>
<data>Memory Usage|85%|<color=warning>⚠️ High</color></data>
<data>Disk Usage|45%|<color=success>✅ Good</color></data>
<divider/>
<row><color=info>📋 Alerts</color></row>
<row><color=warning>⚠️ 3 packages need updates</color></row>
<row><color=error>❌ Backup failed 5 days ago</color></row>
"
parse_html_layout "$layout" 85 "System Dashboard" "major"
```

## Best Practices

### 1. Layout Organization
- Use comments to document sections
- Group related content together
- Use dividers to separate sections logically

### 2. Content Formatting
- Use consistent color schemes
- Use semantic emoji keys
- Keep cell content concise

### 3. Width Considerations
- Choose appropriate widths for your content
- Consider terminal size and readability
- Test with different terminal sizes

### 4. Performance
- Use convenience functions for common patterns
- Use raw layout syntax for complex custom layouts
- Cache layout strings when reusing layouts

## Troubleshooting

### Common Issues

1. **Tags not being parsed**
   - Check for proper tag syntax
   - Ensure no extra spaces in tag names
   - Verify closing tags match opening tags

2. **Content not displaying correctly**
   - Check HTML syntax within cells
   - Verify color and emoji keys are valid
   - Ensure proper escaping of special characters

3. **Layout not rendering**
   - Check that layout string is properly quoted
   - Verify function parameters are correct
   - Ensure box_builder.sh is sourced

### Debug Tips

1. **Test individual tags**
   ```bash
   layout="<row>Test content</row>"
   parse_html_layout "$layout" 50 "Test" "info"
   ```

2. **Check function availability**
   ```bash
   type create_html_box
   type parse_html_layout
   ```

3. **Verify layout parsing**
   ```bash
   # Add debug output to see parsed content
   echo "Layout: $layout"
   ```

## Comparison with Other Approaches

### HTML-like vs Manual
```bash
# HTML-like approach
layout="<header>Name|Status</header><divider/><data>Item|Value</data>"
parse_html_layout "$layout" 60 "Title" "info"

# Manual approach
box_data=$(box_new 60 "Title" "info")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Name")")
row_data=$(row_add_cell "$row_data" "$(make_text "Status")")
box_data=$(box_add_row "$box_data" "$row_data")
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Item")")
row_data=$(row_add_cell "$row_data" "$(make_text "Value")")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
```

### HTML-like vs DSL v2
```bash
# HTML-like approach
create_html_table "Title" 80 "info" "Col1|Col2" "Data1|Data2"

# DSL v2 approach
create_table --title="Title" --width="80" --style="info" --headers "Col1" "Col2" --data "Data1|Data2"
```

## Summary

The HTML-like layout syntax provides:

✅ **Declarative syntax** - Define layouts using familiar HTML-like tags
✅ **Readable format** - Easy to understand and maintain
✅ **Flexible content** - Support for text, colors, emojis, and mixed content
✅ **Convenience functions** - High-level functions for common patterns
✅ **Raw layout support** - Direct control for complex custom layouts
✅ **Comment support** - Document layouts with comments
✅ **Multiple row types** - Support for headers, data, dividers, and custom rows

Choose the HTML-like approach when you want:
- More readable and maintainable layouts
- Familiar HTML-like syntax
- Declarative layout definition
- Complex layouts with mixed content types 