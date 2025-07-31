#!/bin/bash

# Test HTML-like DSL for Layout Builder
# This demonstrates the new declarative DSL syntax for creating layouts

# Get the script directory more reliably
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl.sh"

echo "=== upKep HTML-like DSL Test ==="
echo "This test demonstrates the new declarative DSL syntax"
echo

echo "DSL Syntax Examples:"
echo "• <box style=major title=\"Title\"> - Create a box"
echo "• <row> - Start a new row"
echo "• <cell> - Start a new cell"
echo "• <text color=success>Content</text> - Colored text"
echo "• <emoji key=warning> - Emoji with semantic key"
echo

# Test 1: Simple status box
echo "1. Simple Status Box:"
render_dsl '<box style=info title="System Status" width=50>
  <row>
    <cell><text>System is operational</text></cell>
  </row>
</box>'
echo

# Test 2: Status box with colored content
echo "2. Status Box with Colored Content:"
render_dsl '<box style=success title="Update Complete" width=55>
  <row>
    <cell><text color=success>✅ 12 packages updated successfully</text></cell>
  </row>
  <row>
    <cell><text>⏰ Execution time: 42 seconds</text></cell>
  </row>
</box>'
echo

# Test 3: Table with multiple columns
echo "3. Table with Multiple Columns:"
render_dsl '<box style=info title="Package Status" width=70>
  <row>
    <cell><text>Package</text></cell>
    <cell><text>Status</text></cell>
    <cell><text>Version</text></cell>
  </row>
  <row>
    <cell><text>firefox</text></cell>
    <cell><text color=success>✅ Updated</text></cell>
    <cell><text>91.0</text></cell>
  </row>
  <row>
    <cell><text>git</text></cell>
    <cell><text color=warning>⚠️ Held back</text></cell>
    <cell><text>2.34</text></cell>
  </row>
</box>'
echo

# Test 4: Complex mixed content
echo "4. Complex Mixed Content:"
render_dsl '<box style=warning title="System Warnings" width=60>
  <row>
    <cell><text color=warning>⚠️ Warning: <color=error>Critical error</color> detected</text></cell>
  </row>
  <row>
    <cell><text>🔄 System is attempting to recover...</text></cell>
  </row>
  <row>
    <cell><text color=info>💡 Suggestion: Check logs for details</text></cell>
  </row>
</box>'
echo

# Test 5: Progress information
echo "5. Progress Information:"
render_dsl '<box style=info title="Installation Progress" width=65>
  <row>
    <cell><text>🔄 Processing: 45% complete</text></cell>
  </row>
  <row>
    <cell><text>⏰ Time remaining: 2 minutes</text></cell>
  </row>
  <row>
    <cell><text>📦 Installing: firefox package</text></cell>
  </row>
</box>'
echo

# Test 6: Error box
echo "6. Error Box:"
render_dsl '<box style=error title="Installation Failed" width=55>
  <row>
    <cell><text color=error>❌ Failed to install packages</text></cell>
  </row>
  <row>
    <cell><text>🔍 Error: Network timeout</text></cell>
  </row>
  <row>
    <cell><text color=info>💡 Try: Check internet connection</text></cell>
  </row>
</box>'
echo

# Test 7: Dashboard layout
echo "7. Dashboard Layout:"
render_dsl '<box style=major title="System Dashboard" width=75>
  <row>
    <cell><text>🖥️ System: Ubuntu 22.04 LTS</text></cell>
    <cell><text>💾 Disk: 89.4GB free</text></cell>
  </row>
  <row>
    <cell><text>📊 Total modules: 7</text></cell>
    <cell><text>⏰ Last run: 2 hours ago</text></cell>
  </row>
</box>'
echo

# Test 8: Using helper functions
echo "8. Using Helper Functions:"
create_status_box "Helper Function Test" "info" 50
echo

create_progress_table "Helper Table Test" 70
echo

echo "=== DSL Test Complete ==="
echo
echo "Benefits of DSL syntax:"
echo "✅ Declarative and readable"
echo "✅ HTML-like familiar syntax"
echo "✅ Easy to template and modify"
echo "✅ Self-documenting structure"
echo "✅ Reusable components"
echo
echo "Available tags:"
echo "• <box style=key title=\"text\" width=N> - Create box"
echo "• <row> - Start new row"
echo "• <cell> - Start new cell"
echo "• <text color=key>content</text> - Colored text"
echo "• <emoji key=name> - Semantic emoji"
echo
echo "Available styles: major, minor, emphasis, info, success, warning, error"
echo "Available colors: success, error, warning, info, pending, running, etc."
echo 