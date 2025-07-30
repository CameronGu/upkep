#!/bin/bash

# Test rich visual output for Layout Builder
source ../scripts/core/box_builder.sh

echo "Testing Rich Visual Layout Builder..."
echo

# Test 1: Module Overview Table (Hierarchical)
echo "1. Module Overview Table (Hierarchical):"
box_data=$(box_new 60 "SYSTEM MAINTENANCE STATUS" info)

# Header row
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text 'Module')")
row_data=$(row_add_cell "$row_data" "$(make_text 'Last Run')")
row_data=$(row_add_cell "$row_data" "$(make_text 'Status')")
row_data=$(row_add_cell "$row_data" "$(make_text 'Next Due')")
box_data=$(box_add_row "$box_data" "$row_data")

# Package Updates group
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text 'Package Updates')")
row_data=$(row_add_cell "$row_data" "$(make_text '')")
row_data=$(row_add_cell "$row_data" "$(make_text '')")
row_data=$(row_add_cell "$row_data" "$(make_text '')")
box_data=$(box_add_row "$box_data" "$row_data")

# APT sub-item
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text ' ├─ APT')")
row_data=$(row_add_cell "$row_data" "$(make_text '2 days ago')")
row_data=$(row_add_cell "$row_data" "$(make_emoji success)") 
row_data=$(row_add_cell "$row_data" "$(make_text 'Done')")
box_data=$(box_add_row "$box_data" "$row_data")

# Snap sub-item
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text ' ├─ Snap')")
row_data=$(row_add_cell "$row_data" "$(make_text '2 days ago')")
row_data=$(row_add_cell "$row_data" "$(make_emoji success)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Done')")
box_data=$(box_add_row "$box_data" "$row_data")

# Flatpak sub-item
row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_text ' └─ Flatpak')")
row_data=$(row_add_cell "$row_data" "$(make_text '6 days ago')")
row_data=$(row_add_cell "$row_data" "$(make_emoji warning)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Due')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

# Test 2: Success Box
echo "2. Success Box:"
box_data=$(box_new 50 "APT UPDATE COMPLETE" success)

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji success)")
row_data=$(row_add_cell "$row_data" "$(make_text '12 packages updated successfully')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji timing)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Execution time: 42 seconds')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji package)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Updates: firefox (91.0), git (2.34)')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

# Test 3: Warning Box
echo "3. Warning Box:"
box_data=$(box_new 50 "FLATPAK UPDATE SKIPPED" warning)

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji warning)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Skipped - Last update was 2 days ago')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji info)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Configured interval: 7 days')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

# Test 4: Error Box
echo "4. Error Box:"
box_data=$(box_new 50 "SNAP UPDATE FAILED" error)

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji error)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Failed to refresh snaps')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji timing)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Execution time: 15 seconds')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji suggestion)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Check internet connection and retry')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

# Test 5: Dashboard Status
echo "5. Dashboard Status:"
box_data=$(box_new 60 "upKep System Status" info)

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji info)")
row_data=$(row_add_cell "$row_data" "$(make_text 'System: Ubuntu 22.04 LTS')")
row_data=$(row_add_cell "$row_data" "$(make_emoji info)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Last run: 2 hours ago')")
box_data=$(box_add_row "$box_data" "$row_data")

row_data=$(row_new)
row_data=$(row_add_cell "$row_data" "$(make_emoji stats)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Disk: 89.4GB free')")
row_data=$(row_add_cell "$row_data" "$(make_emoji stats)")
row_data=$(row_add_cell "$row_data" "$(make_text 'Total modules: 7')")
box_data=$(box_add_row "$box_data" "$row_data")

box_render "$box_data"
echo

echo "Rich visual testing complete!" 