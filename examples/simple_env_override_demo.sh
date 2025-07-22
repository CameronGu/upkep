#!/bin/bash
# simple_env_override_demo.sh - Demonstration of Simple Environment Variable Overrides

echo "Simple Environment Variable Override Demo"
echo "========================================"
echo ""

# Source the configuration system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/core/config.sh"

echo "1. Normal Configuration Values:"
echo "   logging.level = $(get_config "logging.level" "info")"
echo "   dry_run = $(get_config "dry_run" "false")"
echo "   parallel_execution = $(get_config "parallel_execution" "true")"
echo "   defaults.update_interval = $(get_config "defaults.update_interval" "7")"
echo ""

echo "2. With Environment Variable Overrides:"
export UPKEP_LOGGING_LEVEL=debug
export UPKEP_DRY_RUN=true
export UPKEP_PARALLEL_EXECUTION=false
export UPKEP_DEFAULTS_UPDATE_INTERVAL=1

echo "   UPKEP_LOGGING_LEVEL=debug"
echo "   UPKEP_DRY_RUN=true"  
echo "   UPKEP_PARALLEL_EXECUTION=false"
echo "   UPKEP_DEFAULTS_UPDATE_INTERVAL=1"
echo ""
echo "   Effective values:"
echo "   logging.level = $(get_config "logging.level" "info")"
echo "   dry_run = $(get_config "dry_run" "false")"
echo "   parallel_execution = $(get_config "parallel_execution" "true")"
echo "   defaults.update_interval = $(get_config "defaults.update_interval" "7")"

# Clean up
unset UPKEP_LOGGING_LEVEL
unset UPKEP_DRY_RUN
unset UPKEP_PARALLEL_EXECUTION
unset UPKEP_DEFAULTS_UPDATE_INTERVAL

echo ""
echo "3. Common Use Cases:"
echo ""
echo "   # Test mode - see what would happen without making changes"
echo "   UPKEP_DRY_RUN=true upkep run"
echo ""
echo "   # Debug mode - verbose logging for troubleshooting"
echo "   UPKEP_LOGGING_LEVEL=debug upkep run"
echo ""
echo "   # Sequential execution - disable parallelism"
echo "   UPKEP_PARALLEL_EXECUTION=false upkep run"
echo ""
echo "   # Force fast updates - override interval checking"
echo "   UPKEP_DEFAULTS_UPDATE_INTERVAL=1 upkep run"
echo ""
echo "   # Combine multiple overrides"
echo "   UPKEP_DRY_RUN=true UPKEP_LOGGING_LEVEL=debug upkep run"
echo ""

echo "Demo Complete!"
echo ""
echo "This simple system provides the flexibility users need"
echo "without the complexity of multi-environment configurations." 