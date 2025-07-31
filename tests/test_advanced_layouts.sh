#!/bin/bash

# Test Advanced Layout Features
# This demonstrates multi-line content, columns, and row dividers

SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/box_builder.sh"

echo "=== Advanced Layout Features Test ==="
echo "This demonstrates multi-line content, columns, and row dividers"
echo

echo "1. Multi-line Content (Single Column):"
# Create a box with multiple rows for multi-line content
box_data=$(box_new 60 "Multi-line Content" "info")

# Row 1: First line
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "This is the first line of content")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 2: Second line
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "This is the second line with more text")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 3: Third line
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "And this is the third line")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "2. Multi-column Layout:"
# Create a box with multiple columns
box_data=$(box_new 80 "Multi-column Layout" "info")

# Row 1: Header row with multiple columns
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Name")")
row_data=$(row_add_cell "$row_data" "$(make_text "Status")")
row_data=$(row_add_cell "$row_data" "$(make_text "Version")")
row_data=$(row_add_cell "$row_data" "$(make_text "Last Updated")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 2: Data row 1
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package A")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Installed</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "1.2.3")")
row_data=$(row_add_cell "$row_data" "$(make_text "2 hours ago")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 3: Data row 2
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package B")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=warning>⚠️ Pending</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "2.1.0")")
row_data=$(row_add_cell "$row_data" "$(make_text "1 day ago")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 4: Data row 3
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Package C")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=error>❌ Failed</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "0.9.5")")
row_data=$(row_add_cell "$row_data" "$(make_text "3 days ago")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "3. Row Dividers (Using Special Row Format):"
# Create a box with row dividers
box_data=$(box_new 70 "Row Dividers Example" "major")

# Row 1: Header
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Section")")
row_data=$(row_add_cell "$row_data" "$(make_text "Details")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 2: Divider (special format)
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Row 3: Content after divider
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "System Info")")
row_data=$(row_add_cell "$row_data" "$(make_text "Ubuntu 22.04 LTS")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 4: Another divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Row 5: More content
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Kernel")")
row_data=$(row_add_cell "$row_data" "$(make_text "5.15.0-generic")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "4. Complex Multi-line with Columns:"
# Create a complex layout with both multi-line and columns
box_data=$(box_new 90 "Complex Layout" "emphasis")

# Row 1: Main header
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<color=info>📊 System Status Report</color>')")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 2: Divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Row 3: Column headers
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Component")")
row_data=$(row_add_cell "$row_data" "$(make_text "Status")")
row_data=$(row_add_cell "$row_data" "$(make_text "Details")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 4: Divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Row 5: CPU info
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "CPU")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Normal</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "4 cores, 25% usage")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 6: Memory info
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Memory")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=warning>⚠️ High</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "8GB total, 85% used")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 7: Disk info
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Disk")")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Good</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "500GB, 45% used")")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 8: Divider
row_data="divider"
box_data=$(box_add_row "$box_data" "$row_data")

# Row 9: Summary
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<color=info>📋 Summary</color>')")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>✅ Overall Good</color>')")
row_data=$(row_add_cell "$row_data" "$(make_text "System running normally")")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "5. Mixed Content Types:"
# Create a box with mixed content types
box_data=$(box_new 75 "Mixed Content Types" "info")

# Row 1: Text and emoji
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Status:")")
row_data=$(row_add_cell "$row_data" "$(make_emoji 'success')")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=success>All systems operational</color>')")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 2: Different content types
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Progress:")")
row_data=$(row_add_cell "$row_data" "$(make_emoji 'running')")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=info>Processing... 45% complete</color>')")
box_data=$(box_add_row "$box_data" "$row_data")

# Row 3: Warning with emoji
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text "Alert:")")
row_data=$(row_add_cell "$row_data" "$(make_emoji 'warning')")
row_data=$(row_add_cell "$row_data" "$(make_html '<color=warning>3 packages need attention</color>')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "=== Advanced Layout Features Summary ==="
echo
echo "✅ Multi-line content: Add multiple rows to a box"
echo "✅ Multi-column layout: Add multiple cells per row"
echo "✅ Row dividers: Use 'divider' as row content"
echo "✅ Mixed content: Combine text, emoji, colors, HTML"
echo "✅ Complex layouts: Combine all features"
echo
echo "Usage Patterns:"
echo "• box_new(width, title, style) - Create box"
echo "• row_new() - Create new row"
echo "• row_add_cell(row, token) - Add cell to row"
echo "• box_add_row(box, row) - Add row to box"
echo "• box_render(box) - Render the box"
echo
echo "Token Types:"
echo "• make_text(content) - Plain text"
echo "• make_emoji(key) - Emoji with semantic key"
echo "• make_html(content) - HTML-like with colors"
echo "• 'divider' - Special row divider"
echo 