# upKep Configuration System Reference

**Date:** 2025-01-23  
**Status:** Current - Hybrid System (Simplified + Legacy)  
**Version:** 2.0.0  

## Table of Contents

1. [System Overview](#system-overview)
2. [Simplified Configuration System](#simplified-configuration-system)
3. [Legacy Configuration System](#legacy-configuration-system)
4. [Environment Variable Overrides](#environment-variable-overrides)
5. [CLI Commands](#cli-commands)
6. [Interval Management](#interval-management)
7. [Testing and Validation](#testing-and-validation)
8. [Migration and Compatibility](#migration-and-compatibility)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## System Overview

upKep uses a **hybrid configuration system** that serves both simple and advanced use cases:

- **Simplified System** (Primary): 262 lines, handles 90% of user needs
- **Legacy System** (Advanced): Full enterprise features for power users
- **Environment Overrides**: Temporary settings via environment variables
- **Zero Breaking Changes**: Full backward compatibility maintained

### Architecture

```
Configuration System
├── Simplified (config_simple.sh)
│   ├── 5 essential settings
│   ├── Single config file (~/.upkep/config.yaml)
│   ├── Pure bash parsing (no external dependencies)
│   └── Environment variable overrides
└── Legacy (config/ directory)
    ├── Complex YAML parsing with yq
    ├── Module-specific configurations
    ├── Advanced validation and migration
    └── Enterprise features
```

## Simplified Configuration System

### Default Configuration File

**Location:** `~/.upkep/config.yaml`  
**Size:** 7 lines  
**Permissions:** 600 (user read/write only)

```yaml
# upKep Configuration - Simple Linux system maintenance settings

update_interval: 7          # Days between package updates
cleanup_interval: 30        # Days between cleanup operations
log_level: info             # Logging: error, warn, info, debug
notifications: true         # Show completion notifications
```

### Core Functions

#### Configuration Management
```bash
# Initialize configuration system
init_simple_config

# Get configuration value (env var > config file > default)
get_config "key" "default_value"

# Set configuration value
set_config "key" "value"

# Show current configuration
show_config

# Reset to defaults
reset_config

# Edit in user's preferred editor
edit_config
```

#### Convenience Functions
```bash
# Get specific settings with sensible defaults
get_update_interval      # Returns: 7 (or env override)
get_cleanup_interval     # Returns: 30 (or env override)
get_log_level           # Returns: info (or env override)
get_notifications_enabled # Returns: true/false

# Check operational modes
is_dry_run              # Returns: true if UPKEP_DRY_RUN=true
is_force_mode           # Returns: true if UPKEP_FORCE=true
```

#### Validation
```bash
# Basic configuration validation
validate_config_basic   # Checks file exists, readable, has basic structure
```

### Implementation Details

**File:** `scripts/core/config_simple.sh`  
**Lines:** 262  
**Dependencies:** None (pure bash)

#### Key Features
- **Environment Variable Priority**: `UPKEP_KEY_NAME` overrides config file
- **Simple YAML Parsing**: Basic key-value extraction without external tools
- **Atomic Updates**: Uses temporary files for safe configuration changes
- **Secure Permissions**: Config files created with 600 permissions
- **Comment Handling**: Strips inline comments (`#`) from values
- **Quote Handling**: Removes surrounding quotes while preserving content

## Legacy Configuration System

### Enhanced YAML Parsing

**File:** `scripts/core/yaml_utils.sh`  
**Lines:** 370  
**Dependencies:** Optional `yq` for advanced features

#### Supported Nesting Levels
```yaml
# Level 1: Simple keys
debug: false
timeout: 30

# Level 2: Two-level nesting
defaults:
  update_interval: 7
  cleanup_interval: 30

# Level 3: Three-level nesting
modules:
  apt_update:
    enabled: true
    interval_days: 7

# Level 4+: Generic path-based parsing
modules:
  apt_update:
    options:
      auto_remove: true
      timeout: 600
```

#### Core Functions
```bash
# Enhanced YAML parsing with yq fallback
get_yaml_config "file.yaml" "key.path" "default"

# Set YAML configuration (requires yq)
set_yaml_config "file.yaml" "key.path" "value"

# Validate YAML structure
validate_yaml_structure "file.yaml"
```

#### Advanced Features
- **Smart Quote Removal**: Preserves internal quotes, removes surrounding quotes
- **Boolean Handling**: Proper handling of `true`/`false`/`null` values
- **Comment Skipping**: Ignores YAML comments and empty lines
- **Indentation Awareness**: Handles 2-space indentation properly
- **Error Recovery**: Graceful fallback when yq is unavailable

### Module-Specific Configuration

**Directory:** `~/.upkep/modules/`  
**Format:** Individual YAML files per module

```yaml
# ~/.upkep/modules/apt_update.yaml
enabled: true
interval_days: 7
description: "APT package updates"
priority: high
options:
  auto_remove: true
  timeout: 600
```

## Environment Variable Overrides

### Priority Order
1. **Environment Variables** (highest priority)
2. **Configuration File** (middle priority)
3. **Default Values** (lowest priority)

### Supported Environment Variables

#### Operational Overrides
```bash
UPKEP_DRY_RUN=true          # Test mode (show what would be done)
UPKEP_FORCE=true            # Skip interval checks
```

#### Configuration Overrides
```bash
UPKEP_UPDATE_INTERVAL=3     # Override update interval
UPKEP_CLEANUP_INTERVAL=7    # Override cleanup interval
UPKEP_LOG_LEVEL=debug       # Override logging level
UPKEP_NOTIFICATIONS=false   # Disable notifications
```

#### Legacy System Overrides
```bash
UPKEP_DEFAULTS_UPDATE_INTERVAL=14    # Nested key override
UPKEP_MODULES_APT_UPDATE_ENABLED=false # Deep nested override
```

### Environment Variable Naming Convention

**Pattern:** `UPKEP_<KEY_NAME>`  
**Conversion:** Dots (`.`) and lowercase become underscores (`_`) and uppercase

```bash
# Config key: defaults.update_interval
# Env var: UPKEP_DEFAULTS_UPDATE_INTERVAL

# Config key: modules.apt_update.enabled
# Env var: UPKEP_MODULES_APT_UPDATE_ENABLED
```

## CLI Commands

### Configuration Management Commands

```bash
# Show current configuration
upkep config show

# Edit configuration in $EDITOR
upkep config edit

# Reset to default configuration
upkep config reset

# Get specific setting value
upkep config get update_interval

# Set specific setting value
upkep config set update_interval 14
```

### Command Examples

```bash
# View current configuration and environment overrides
$ upkep config show
upKep Configuration
===================
update_interval: 7
cleanup_interval: 30
log_level: info
notifications: true

Environment Overrides:
======================
UPKEP_DRY_RUN=not set
UPKEP_FORCE=not set
UPKEP_LOG_LEVEL=not set
UPKEP_UPDATE_INTERVAL=not set
UPKEP_CLEANUP_INTERVAL=not set

# Set a configuration value
$ upkep config set update_interval 3
Set update_interval = 3

# Get a specific value
$ upkep config get log_level
info

# Test with environment override
$ UPKEP_LOG_LEVEL=debug upkep config get log_level
debug
```

## Interval Management

### Category-Based Intervals

upKep uses category-based intervals to balance system freshness, performance, and stability:

#### Default Categories
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 7    # Days between package updates
    system_cleanup:
      default_interval: 3    # Days between cleanup operations
    security:
      default_interval: 3    # Days between security checks
    monitoring:
      default_interval: 3    # Days between monitoring checks
```

#### Recommended Intervals

| Category | Default | Range | Rationale |
|----------|---------|-------|-----------|
| **Package Managers** | 7 days | 3-7 days | Balance security with stability |
| **System Cleanup** | 3 days | 1-3 days | Prevent disk space issues |
| **Security** | 3 days | 1-3 days | Maintain security posture |
| **Monitoring** | 3 days | 1-7 days | Provide visibility |

#### Module-Specific Overrides
```yaml
modules:
  apt_update:
    enabled: true
    category: package_managers
    interval_days: 3  # Override category default
    interval_override:
      enabled: true
      interval_days: 3
      reason: "Security updates should be applied more frequently"
```

### Configuration Examples

#### Conservative Setup (Recommended)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 7
    system_cleanup:
      default_interval: 3
    security:
      default_interval: 3
    monitoring:
      default_interval: 3
```

#### Aggressive Setup (Power Users)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 3
    system_cleanup:
      default_interval: 1
    security:
      default_interval: 1
    monitoring:
      default_interval: 1
```

#### Minimal Setup (Resource-Constrained)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 14
    system_cleanup:
      default_interval: 7
    security:
      default_interval: 7
    monitoring:
      default_interval: 7
```

## Testing and Validation

### Test Coverage

**Total Tests:** 14  
**Success Rate:** 100%  
**Coverage:** Both simplified and legacy systems

#### Simplified System Tests
```bash
# Run simplified configuration tests
./tests/test_cases/test_simple_config_system.sh

# Tests include:
✓ Configuration Initialization
✓ Basic Configuration Reading
✓ Configuration Writing
✓ Environment Variable Overrides
✓ Convenience Functions
✓ Boolean Functions
✓ Default Value Fallback
✓ Configuration Reset
✓ Configuration Validation
✓ Quote Handling
✓ File Permissions
```

#### Enhanced YAML Parsing Tests
```bash
# Run enhanced YAML parsing tests
./tests/test_cases/test_enhanced_yaml_parsing.sh

# Tests include:
✓ Simple Key Parsing
✓ Two-Level Nested Parsing
✓ Three-Level Nested Parsing
✓ Edge Cases and Special Values
✓ Default Value Fallback
✓ Setting Simple Keys
✓ Setting Nested Keys
✓ Setting Deep Nested Keys
✓ Module Config Parsing
✓ Module Nested Parsing
✓ Module Config Setting
✓ YAML Structure Validation
✓ Error Handling
✓ Environment Variable Overrides
```

#### Environment Override Tests
```bash
# Run environment variable override tests
./tests/test_cases/test_simple_env_overrides.sh

# Tests include:
✓ Basic Config Reading
✓ Environment Variable Override
✓ Key Formats
✓ Fallback to Config
✓ Fallback to Default
✓ Notifications Setting
```

### Validation Functions

#### Simplified System Validation
```bash
# Basic validation (file exists, readable, has structure)
validate_config_basic

# Returns: 0 (success) or 1 (failure)
```

#### Legacy System Validation
```bash
# YAML structure validation
validate_yaml_structure "config.yaml"

# Returns: 0 (valid) or 1 (invalid)
```

## Migration and Compatibility

### Backward Compatibility

**Status:** 100% compatible  
**Breaking Changes:** None  
**Migration Required:** None

#### Legacy Configuration Support
- All existing configuration files continue to work
- Legacy YAML parsing functions remain available
- Module-specific configurations supported
- Environment variable overrides work with both systems

#### Automatic Migration
- New installations use simplified system by default
- Existing installations continue using current configuration
- Users can manually migrate to simplified system if desired

### Migration Paths

#### To Simplified System
```bash
# 1. Backup current configuration
cp ~/.upkep/config.yaml ~/.upkep/config.yaml.backup

# 2. Reset to simplified defaults
upkep config reset

# 3. Customize as needed
upkep config set update_interval 3
upkep config set cleanup_interval 7
```

#### To Legacy System
```bash
# 1. Use legacy configuration functions
source scripts/core/yaml_utils.sh

# 2. Create complex configuration
cat > ~/.upkep/config.yaml << 'EOF'
version: 2.0.0
defaults:
  update_interval: 7
  cleanup_interval: 30
modules:
  apt_update:
    enabled: true
    interval_days: 7
EOF
```

## Best Practices

### Configuration Management

1. **Start Simple**: Begin with simplified system for new installations
2. **Use Environment Variables**: For testing and temporary overrides
3. **Document Changes**: Keep notes on custom configurations
4. **Backup Configurations**: Before making significant changes
5. **Test Changes**: Use `--dry-run` to test new configurations

### Interval Configuration

1. **Start Conservative**: Begin with category defaults
2. **Monitor Performance**: Watch for issues when changing intervals
3. **Document Overrides**: Always provide reasons for custom intervals
4. **Test Gradually**: Make small changes and observe system behavior
5. **Consider Resources**: Adjust intervals based on system capabilities

### Security Considerations

1. **File Permissions**: Configuration files use 600 permissions
2. **Environment Variables**: Be careful with sensitive data in environment
3. **Validation**: Always validate configuration changes
4. **Backup**: Keep backups of working configurations
5. **Testing**: Test configurations in safe environments first

### Performance Optimization

1. **Minimal Configuration**: Use simplified system when possible
2. **Efficient Intervals**: Balance freshness with system load
3. **Resource Monitoring**: Watch for performance impact of frequent operations
4. **Selective Modules**: Enable only necessary modules
5. **Logging Levels**: Use appropriate log levels for production

## Troubleshooting

### Common Issues

#### Configuration Not Loading
```bash
# Check file permissions
ls -la ~/.upkep/config.yaml

# Should show: -rw------- (600 permissions)

# Check file exists and is readable
cat ~/.upkep/config.yaml

# Reset if corrupted
upkep config reset
```

#### Environment Variables Not Working
```bash
# Check variable name format
echo $UPKEP_UPDATE_INTERVAL

# Verify naming convention
# Config key: update_interval
# Env var: UPKEP_UPDATE_INTERVAL

# Test with explicit export
export UPKEP_UPDATE_INTERVAL=3
upkep config get update_interval
```

#### YAML Parsing Issues
```bash
# Check YAML syntax
yq eval . ~/.upkep/config.yaml

# Validate structure
source scripts/core/yaml_utils.sh
validate_yaml_structure ~/.upkep/config.yaml

# Check for common issues:
# - Unbalanced quotes
# - Incorrect indentation
# - Invalid characters
```

#### Interval Problems
```bash
# Check current intervals
upkep config get update_interval
upkep config get cleanup_interval

# Verify environment overrides
echo $UPKEP_UPDATE_INTERVAL
echo $UPKEP_CLEANUP_INTERVAL

# Test interval logic
UPKEP_FORCE=true upkep run
```

### Debug Mode

#### Enable Debug Logging
```bash
# Set debug log level
export UPKEP_LOG_LEVEL=debug

# Or set in configuration
upkep config set log_level debug
```

#### Dry Run Mode
```bash
# Test configuration without making changes
export UPKEP_DRY_RUN=true
upkep run
```

#### Force Mode
```bash
# Skip interval checks
export UPKEP_FORCE=true
upkep run
```

### Getting Help

#### Configuration Commands
```bash
# Show help for config commands
upkep config

# Show specific command help
upkep config get
upkep config set
```

#### Test Configuration
```bash
# Run all configuration tests
./tests/test_runner.sh

# Run specific test suites
./tests/test_cases/test_simple_config_system.sh
./tests/test_cases/test_enhanced_yaml_parsing.sh
./tests/test_cases/test_simple_env_overrides.sh
```

#### Log Files
```bash
# Check upKep logs
tail -f ~/.upkep/logs/upkep.log

# Check system logs for upKep
journalctl -u upkep -f
```

---

## Appendix

### Configuration File Locations

| System | Primary Config | Module Configs | Logs |
|--------|----------------|----------------|------|
| **Simplified** | `~/.upkep/config.yaml` | N/A | `~/.upkep/logs/` |
| **Legacy** | `~/.upkep/config.yaml` | `~/.upkep/modules/` | `~/.upkep/logs/` |

### Function Reference

#### Simplified System Functions
- `init_simple_config()` - Initialize configuration system
- `get_config(key, default)` - Get configuration value
- `set_config(key, value)` - Set configuration value
- `show_config()` - Display current configuration
- `reset_config()` - Reset to defaults
- `edit_config()` - Edit in editor
- `validate_config_basic()` - Basic validation

#### Legacy System Functions
- `get_yaml_config(file, key, default)` - Enhanced YAML parsing
- `set_yaml_config(file, key, value)` - Set YAML value
- `validate_yaml_structure(file)` - YAML validation
- `get_module_config(module, key, default)` - Module config
- `set_module_config(module, key, value)` - Set module config

#### Utility Functions
- `smart_quote_removal(value)` - Handle quoted values
- `format_yaml_value(value)` - Format YAML values
- `should_skip_yaml_line(line)` - Skip comments/empty lines

### Environment Variable Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `UPKEP_DRY_RUN` | Test mode | `UPKEP_DRY_RUN=true` |
| `UPKEP_FORCE` | Skip intervals | `UPKEP_FORCE=true` |
| `UPKEP_LOG_LEVEL` | Logging level | `UPKEP_LOG_LEVEL=debug` |
| `UPKEP_UPDATE_INTERVAL` | Update interval | `UPKEP_UPDATE_INTERVAL=3` |
| `UPKEP_CLEANUP_INTERVAL` | Cleanup interval | `UPKEP_CLEANUP_INTERVAL=7` |
| `UPKEP_NOTIFICATIONS` | Notifications | `UPKEP_NOTIFICATIONS=false` |

---

*This reference document provides comprehensive information about upKep's configuration system. For specific implementation details, see the individual source files and test cases.* 