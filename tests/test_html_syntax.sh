#!/bin/bash

# Test HTML-like syntax for Layout Builder
# This demonstrates the new simplified HTML-like syntax for composite cells

source scripts/core/box_builder.sh

echo "=== upKep HTML-like Layout Builder Test ==="
echo "This test demonstrates the new HTML-like syntax for composite cells"
echo

echo "HTML-like syntax examples:"
echo "• <color=warning>text</color> - colored text"
echo "• <emoji=success> - emoji with semantic key"
echo "• <reset> - reset color"
echo "• Mixed: <color=error>Error</color> <emoji=warning> Warning"
echo

# Test 1: Simple colored text
echo "1. Simple colored text:"
box_data=$(box_new 40 "COLORED TEXT TEST" info)
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html 'Normal text <color=success>success text</color> normal again')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

# Test 2: Emoji with text
echo "2. Emoji with text:"
box_data=$(box_new 40 "EMOJI TEST" info)
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=success> Success message')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=error> Error message')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

# Test 3: Complex mixed content
echo "3. Complex mixed content:"
box_data=$(box_new 50 "MIXED CONTENT TEST" info)
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=warning> <color=warning>Warning:</color> <color=error>Critical error</color> detected')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=success> <color=success>Success:</color> All systems operational')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

# Test 4: Status indicators
echo "4. Status indicators:"
box_data=$(box_new 45 "STATUS INDICATORS" info)
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html 'APT: <color=success>✅ Updated</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html 'Snap: <color=warning>⚠️ 3 held back</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html 'Network: <color=error>❌ Failed</color>')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

# Test 5: Progress information
echo "5. Progress information:"
box_data=$(box_new 50 "PROGRESS INFO" info)
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=running> <color=info>Processing:</color> 45% complete')")
box_data=$(box_add_row "$box_data" "$row_data")
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_html '<emoji=timing> <color=timing>Time:</color> 2 minutes remaining')")
box_data=$(box_add_row "$box_data" "$row_data")
box_render "$box_data"
echo

echo "=== HTML-like Syntax Test Complete ==="
echo
echo "Benefits of HTML-like syntax:"
echo "✅ More intuitive and readable"
echo "✅ Familiar to web developers"
echo "✅ Easy to mix colors, emojis, and text"
echo "✅ Self-closing tags for simple elements"
echo "✅ Proper color reset handling"
echo
echo "Available tags:"
echo "• <color=key>text</color> - colored text (key: success, error, warning, info, etc.)"
echo "• <emoji=key> - emoji (key: success, error, warning, running, etc.)"
echo "• <reset> - reset color immediately"
echo 