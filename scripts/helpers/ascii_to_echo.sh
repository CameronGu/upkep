#!/bin/bash
# ascii_to_echo.sh
# A helper script to convert ASCII art into bash-friendly echo statements.

echo "Paste your ASCII art below. Press Ctrl+D (Linux/Mac) or Ctrl+Z then Enter (Windows) when done."

# Read the entire input into a variable
input=$(cat)

# # Split into lines and process
# while IFS= read -r line; do
#     escaped=$(echo "$line" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g')
#     echo "echo \"$escaped\""
# done <<< "$input"

# Process each line and escape necessary characters
while IFS= read -r line; do
    escaped=$(echo "$line" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/`/\\`/g' \
        -e 's/\$/\\$/g')
    echo "echo \"$escaped\""
done <<< "$input"