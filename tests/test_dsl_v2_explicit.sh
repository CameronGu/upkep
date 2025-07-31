#!/bin/bash

# Test DSL v2 with Explicit Parameters
# This demonstrates the improved DSL that avoids attribute ambiguity

# Get the script directory more reliably
SCRIPT_DIR="$(cd "$(dirname "$0")/../scripts/core" && pwd)"
source "${SCRIPT_DIR}/layout_dsl_v2.sh"

echo "=== DSL v2 with Explicit Parameters Test ==="
echo "This demonstrates the improved DSL that avoids attribute ambiguity"
echo

echo "1. Basic Box with Explicit Parameters:"
create_box --title="System Status" --content="All systems operational" --style="success" --width="50"
echo

echo "2. Box with Content that Contains Attribute Names (No Ambiguity!):"
create_box --title="Ambiguous Content" --content="The color is success and the style is warning" --style="info" --width="60"
echo

echo "3. Box with HTML-like Content (No Ambiguity!):"
create_box --title="HTML-like Content" --content="Use color=success for green text" --style="info" --width="60"
echo

echo "4. Success Box with Explicit Parameters:"
create_success_box --title="Update Complete" --content="12 packages updated successfully" --width="55"
echo

echo "5. Warning Box with Explicit Parameters:"
create_warning_box --title="System Warning" --content="3 packages held back due to dependencies" --width="60"
echo

echo "6. Error Box with Explicit Parameters:"
create_error_box --title="Installation Failed" --content="Network timeout during download" --width="60"
echo

echo "7. Info Box with Explicit Parameters:"
create_info_box --title="System Info" --content="Check logs for detailed information" --width="60"
echo

echo "8. Custom Box with Mixed Attributes:"
create_box --title="Custom Box" --content="This is custom content" --color="warning" --emoji="🔧" --style="info" --width="55"
echo

echo "9. Table with Explicit Parameters:"
create_table --title="Package Status" --width="70" --style="info" "Package" "Status" "Version" "Last Updated"
echo

echo "10. Dashboard with Explicit Parameters:"
create_dashboard --title="System Dashboard" --width="70" --style="major" "🖥️ System: Ubuntu 22.04 LTS" "💾 Disk: 89.4GB free" "📊 Total modules: 7"
echo

echo "11. Progress Box with Explicit Parameters:"
create_progress --title="Installation Progress" --message="Processing" --progress="45% complete" --emoji="🔄" --width="60"
echo

echo "=== Comparison: Old vs New ==="
echo

echo "OLD WAY (Ambiguous):"
echo "  create_quick_box \"Title\" \"The color is success\" \"info\" 50"
echo "  ❌ Content could be confused with attributes"
echo

echo "NEW WAY (Explicit):"
echo "  create_box --title=\"Title\" --content=\"The color is success\" --style=\"info\" --width=\"50\""
echo "  ✅ No ambiguity - attributes are clearly marked"
echo

echo "=== Benefits of Explicit Parameters ==="
echo "✅ No ambiguity between content and attributes"
echo "✅ Self-documenting - clear what each parameter does"
echo "✅ Flexible order - parameters can be in any order"
echo "✅ Optional parameters - only specify what you need"
echo "✅ Backward compatible - old functions still work"
echo "✅ Extensible - easy to add new parameters"
echo

echo "=== Usage Examples ==="
echo
echo "Basic box:"
echo "  create_box --title=\"Title\" --content=\"Content\""
echo
echo "Colored box:"
echo "  create_box --title=\"Title\" --content=\"Content\" --color=\"success\""
echo
echo "Box with emoji:"
echo "  create_box --title=\"Title\" --content=\"Content\" --emoji=\"✅\" --color=\"success\""
echo
echo "Success box (convenience):"
echo "  create_success_box --title=\"Title\" --content=\"Content\""
echo 