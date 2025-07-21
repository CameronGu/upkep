#!/bin/bash
# create_structure.sh
# Script to set up the upKept folder structure in the current directory.

BASE_DIR="./"

# Create directories
mkdir -p "$BASE_DIR/scripts/modules"
mkdir -p "$BASE_DIR/logs/modules"
mkdir -p "$BASE_DIR/tests/mocks"
mkdir -p "$BASE_DIR/tests/test_cases"
mkdir -p "$BASE_DIR/docs"
mkdir -p "$BASE_DIR/examples"

# Create placeholder files
touch "$BASE_DIR/scripts/update_all.sh"
touch "$BASE_DIR/scripts/ascii_art.sh"
touch "$BASE_DIR/scripts/modules/apt_update.sh"
touch "$BASE_DIR/scripts/modules/snap_update.sh"
touch "$BASE_DIR/scripts/modules/flatpak_update.sh"
touch "$BASE_DIR/scripts/modules/cleanup.sh"
touch "$BASE_DIR/scripts/modules/security_checks.sh"
touch "$BASE_DIR/scripts/modules/utils.sh"

touch "$BASE_DIR/logs/run.log"
touch "$BASE_DIR/logs/modules/apt.log"
touch "$BASE_DIR/logs/modules/snap.log"
touch "$BASE_DIR/logs/modules/flatpak.log"

touch "$BASE_DIR/tests/test_runner.sh"
touch "$BASE_DIR/tests/mocks/mock_apt.sh"
touch "$BASE_DIR/tests/mocks/mock_snap.sh"
touch "$BASE_DIR/tests/test_cases/test_interval_logic.sh"
touch "$BASE_DIR/tests/test_cases/test_flags.sh"
touch "$BASE_DIR/tests/test_cases/test_formatting.sh"
touch "$BASE_DIR/tests/test_cases/test_summary_box.sh"

touch "$BASE_DIR/docs/README.md"
touch "$BASE_DIR/docs/CHANGELOG.md"
touch "$BASE_DIR/docs/DESIGN.md"

touch "$BASE_DIR/examples/taskmaster_example.log"

# Optional Makefile
touch "$BASE_DIR/Makefile"

echo "Project folder structure created at $BASE_DIR."