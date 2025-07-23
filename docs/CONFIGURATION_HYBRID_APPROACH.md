# upKep Configuration System - Hybrid Approach Documentation

## Current State: Dual Configuration Systems

upKep currently operates with **two parallel configuration systems** during the transition period. This hybrid approach ensures full backward compatibility while providing a simplified path forward.

## System Overview

### 1. Simplified Configuration System (New - Recommended)
**File:** `scripts/core/config_simple.sh` (262 lines)
**Used by:** Main execution path (`scripts/main.sh`)

**Features:**
- ✅ **5 essential settings:** `update_interval`, `cleanup_interval`, `log_level`, `notifications`, `parallel_execution`
- ✅ **Single config file:** `~/.upkep/config.yaml` (7 lines)
- ✅ **Environment overrides:** `UPKEP_DRY_RUN`, `UPKEP_FORCE`, etc.
- ✅ **Simple CLI:** `upkep config show|edit|reset|get|set`
- ✅ **No external dependencies:** Pure bash YAML parsing
- ✅ **30-second setup time**

**Configuration Example:**
```yaml
# upKep Configuration - Simple Linux system maintenance settings

update_interval: 7          # Days between package updates
cleanup_interval: 30        # Days between cleanup operations
log_level: info             # Logging: error, warn, info, debug
notifications: true         # Show completion notifications
parallel_execution: true    # Run operations in parallel
```

### 2. Enhanced Configuration System (Legacy - Still Active)
**Files:** `scripts/core/config/global.sh` (782 lines) + `module.sh` (576 lines)
**Used by:** Advanced features, module configurations, JSON export

**Features:**
- ✅ **Complex YAML parsing** with yq integration and fallbacks
- ✅ **Module-specific configurations** in `~/.upkep/modules/`
- ✅ **Multi-level nesting** support (up to 3+ levels deep)
- ✅ **Advanced validation** and error handling
- ✅ **JSON export functionality**
- ✅ **Interactive configuration wizards**

## User Experience

### For New Users (Recommended Path)
**Default Experience:** Uses simplified system automatically
```bash
# Works immediately with sensible defaults
upkep run

# Simple configuration management
upkep config show              # View current settings
upkep config set log_level debug    # Change a setting
upkep config edit              # Edit in your preferred editor

# Environment overrides for testing
UPKEP_DRY_RUN=true upkep run   # Test mode
```

### For Advanced Users (Legacy Path)
**Complex Configuration:** Still fully supported
```bash
# Access advanced configuration features
upkep config --show           # Legacy CLI syntax
upkep config --set logging.level=debug
upkep config --export json

# Module-specific configuration (if needed)
# Advanced YAML parsing with nested structures
```

## Migration Strategy

### Phase 1: Coexistence (Current State) ✅
- ✅ Both systems working in parallel
- ✅ Main execution uses simplified system
- ✅ Advanced features use legacy system
- ✅ Full backward compatibility maintained
- ✅ All tests passing (14/14 - 100% success rate)

### Phase 2: Gradual Migration (Future)
- **Goal:** Gradually move advanced features to simplified approach
- **Approach:** Feature-by-feature migration with extensive testing
- **Timeline:** As needed based on user feedback and maintenance burden

### Phase 3: Full Unification (Long-term Goal)
- **Goal:** Single, unified configuration system
- **Approach:** Retain simplicity while supporting necessary complexity
- **Decision:** Based on actual user needs vs theoretical enterprise features

## Technical Details

### How Systems Interact
1. **Main execution path** (`scripts/main.sh`) uses simplified system
2. **CLI interface** (`scripts/core/cli.sh`) bridges both systems
3. **Advanced features** continue using legacy system
4. **Tests cover both systems** independently

### File Structure
```
upkep/
├── scripts/core/
│   ├── config_simple.sh       # New simplified system (262 lines)
│   ├── config.sh              # Legacy orchestrator (still used)
│   └── config/
│       ├── global.sh          # Legacy complex system (782 lines)
│       └── module.sh          # Legacy module system (576 lines)
└── tests/test_cases/
    ├── test_simple_config_system.sh    # New system tests (11 tests)
    └── test_enhanced_yaml_parsing.sh   # Legacy system tests (14 tests)
```

### Environment Variables
Both systems support environment overrides:
```bash
# Works with both systems
UPKEP_DRY_RUN=true           # Enable test mode
UPKEP_FORCE=true             # Skip interval checks  
UPKEP_LOG_LEVEL=debug        # Override log level
UPKEP_UPDATE_INTERVAL=1      # Override update interval
```

## Developer Guidelines

### When to Use Each System

**Use Simplified System for:**
- ✅ New feature development
- ✅ Main execution logic
- ✅ Basic configuration needs
- ✅ User-facing interfaces

**Use Legacy System for:**
- ✅ Module-specific configurations (until migrated)
- ✅ Complex YAML structures (until simplified)
- ✅ JSON export functionality (until replaced)
- ✅ Advanced parsing needs (until alternatives ready)

### Adding New Configuration Options

**For Simple Settings:**
1. Add to `DEFAULT_CONFIG` in `config_simple.sh`
2. Create getter function (e.g., `get_new_setting()`)
3. Add to CLI help text
4. Add test cases

**For Complex Settings:**
1. Use legacy system temporarily
2. Plan migration to simplified approach
3. Document decision rationale

## Benefits of Hybrid Approach

### ✅ Advantages
- **Zero breaking changes** for existing users
- **Immediate simplification** for new users
- **Gradual migration path** reduces risk
- **Full test coverage** for both systems
- **Flexibility** to choose appropriate complexity level

### ⚠️ Considerations
- **Two systems to maintain** during transition
- **Code complexity** from supporting both approaches
- **Documentation overhead** explaining dual system

## Future Direction

The hybrid approach is **intentionally temporary**. The long-term goal is a unified system that:

1. **Maintains the simplicity** of the new approach for 90% of use cases
2. **Supports necessary complexity** for the remaining 10% without enterprise bloat  
3. **Provides smooth migration path** for all existing functionality
4. **Eliminates maintenance burden** of dual systems

## User Recommendations

### For New Users
- ✅ **Use the simplified system** - it covers all common needs
- ✅ **Start with defaults** - they work for most Linux maintenance
- ✅ **Use environment variables** for testing and temporary changes

### For Existing Users  
- ✅ **Current configurations continue working** unchanged
- ✅ **No immediate action required** - existing setup remains functional
- ✅ **Consider simplified approach** for new configurations
- ✅ **Gradual migration recommended** but not required

---

*This hybrid approach ensures upKep continues serving both simple personal use cases and more complex requirements while transitioning toward a unified, user-focused solution.* 