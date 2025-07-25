#!/bin/bash
# simple_env_override_demo.sh - Demonstration of Simple Environment Variable Overrides

echo "Simple Environment Variable Override Demo"
echo "========================================"
echo ""

# Source the configuration system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/core/config.sh"

echo "Current configuration values:"
echo "   update_interval = $(get_config "update_interval" "7")"
echo "   cleanup_interval = $(get_config "cleanup_interval" "30")"
echo "   log_level = $(get_config "log_level" "info")"
echo "   notifications = $(get_config "notifications" "true")"
echo ""

echo "Setting environment variable override..."
export UPKEP_NOTIFICATIONS=false

echo "   UPKEP_NOTIFICATIONS=false"
echo ""

echo "Configuration values after override:"
echo "   update_interval = $(get_config "update_interval" "7")"
echo "   cleanup_interval = $(get_config "cleanup_interval" "30")"
echo "   log_level = $(get_config "log_level" "info")"
echo "   notifications = $(get_config "notifications" "true")"
echo ""

echo "Clearing environment variable..."
unset UPKEP_NOTIFICATIONS

echo "Configuration values after clearing:"
echo "   update_interval = $(get_config "update_interval" "7")"
echo "   cleanup_interval = $(get_config "cleanup_interval" "30")"
echo "   log_level = $(get_config "log_level" "info")"
echo "   notifications = $(get_config "notifications" "true")"
echo ""

echo "Example usage with environment overrides:"
echo "   UPKEP_DRY_RUN=true upkep run"
echo "   UPKEP_FORCE=true upkep run"
echo "   UPKEP_LOG_LEVEL=debug upkep run"
echo "   UPKEP_UPDATE_INTERVAL=1 upkep run"
echo "   UPKEP_NOTIFICATIONS=false upkep run"