#!/bin/bash

# Test Simple DSL for Layout Builder
# This demonstrates the simplified DSL approach

# Get the script directory more reliably
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl.sh"

echo "=== upKep Simple DSL Test ==="
echo "This test demonstrates the simplified DSL approach"
echo

echo "Simple DSL Examples:"
echo "• create_quick_box title content style width"
echo "• create_quick_table title header1 header2 header3"
echo "• render_dsl with HTML-like templates"
echo

# Test 1: Simple quick box
echo "1. Simple Quick Box:"
create_quick_box "System Status" "All systems operational" "success" 45
echo

# Test 2: Quick table
echo "2. Quick Table:"
create_quick_table "Package Status" "Package" "Status" "Version" 60
echo

# Test 3: Simple DSL template
echo "3. Simple DSL Template:"
render_dsl '<box style=info title="Update Status" width=50>
  <row>
    <cell><text color=success>✅ 12 packages updated</text></cell>
  </row>
</box>'
echo

# Test 4: Warning box
echo "4. Warning Box:"
create_quick_box "System Warning" "⚠️ 3 packages held back" "warning" 45
echo

# Test 5: Error box
echo "5. Error Box:"
create_quick_box "Installation Failed" "❌ Network timeout" "error" 45
echo

# Test 6: Info box with emoji
echo "6. Info Box with Emoji:"
create_quick_box "Progress" "🔄 Processing: 45% complete" "info" 50
echo

# Test 7: Helper functions
echo "7. Helper Functions:"
create_status_box "Helper Status" "info" 50
echo

echo "=== Simple DSL Test Complete ==="
echo
echo "Benefits of Simple DSL:"
echo "✅ Easy to use and understand"
echo "✅ Quick creation of common layouts"
echo "✅ Template-based approach"
echo "✅ Extensible for complex cases"
echo
echo "Available functions:"
echo "• create_quick_box(title, content, style, width)"
echo "• create_quick_table(title, headers...)"
echo "• render_dsl(template_string)"
echo "• create_status_box(title, style, width)"
echo 