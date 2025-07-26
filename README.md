# upKep - Linux System Maintenance Tool

A modular, extensible system maintenance tool for Linux that automates common maintenance tasks with intelligent scheduling and comprehensive logging.

## Features

- **Modular Architecture**: Dynamic module discovery and loading from multiple paths
- **Intelligent Scheduling**: Interval-based execution with caching to prevent redundant operations
- **Comprehensive Logging**: Multi-level logging with rotation and structured output
- **State Management**: Persistent state tracking for modules and global operations
- **Configuration Management**: YAML-based configuration with validation
- **Enhanced Visual Interface**: Terminal-first design with semantic colors, dynamic boxes, and Unicode-aware alignment
- **Accessibility**: Colorblind-friendly mode with high-contrast colors and text indicators
- **AI Integration**: AI prompt generation for module development
- **Extensible**: Easy to create custom modules with templates

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/camerongu/upkep.git
cd upkep

# Build and install
make build install
```

### Basic Usage

```bash
# Run all enabled modules
upkep run

# Show status of all modules
upkep status

# List available modules
upkep list-modules

# Show configuration
upkep config --show

# Enable colorblind-friendly mode
upkep colorblind on
```

## Troubleshooting

upkep provides optional file logging to help troubleshoot issues when they occur.

### Enable File Logging

By default, upkep only displays output to the console. To enable persistent file logging for debugging:

```bash
# Enable file logging for a single run
UPKEP_LOG_TO_FILE=true upkep run

# View the log file
cat ~/.upkep/upkep.log
```

### Log Levels

Control the verbosity of logging with the `UPKEP_LOGGING_LEVEL` environment variable:

```bash
# Debug level (most verbose) - shows all messages
UPKEP_LOGGING_LEVEL=debug UPKEP_LOG_TO_FILE=true upkep run

# Info level (default) - shows info, warnings, and errors
UPKEP_LOGGING_LEVEL=info UPKEP_LOG_TO_FILE=true upkep run

# Warning level - shows only warnings and errors
UPKEP_LOGGING_LEVEL=warn UPKEP_LOG_TO_FILE=true upkep run

# Error level (least verbose) - shows only errors
UPKEP_LOGGING_LEVEL=error UPKEP_LOG_TO_FILE=true upkep run
```

### Common Debugging Workflows

**When something fails:**
```bash
# Run with debug logging to capture detailed information
UPKEP_LOG_TO_FILE=true UPKEP_LOGGING_LEVEL=debug upkep run

# Review the log file for errors
cat ~/.upkep/upkep.log | grep -i error

# Or view the full log with timestamps
cat ~/.upkep/upkep.log
```

**Testing configuration changes:**
```bash
# Use dry-run mode with logging to see what would happen
UPKEP_DRY_RUN=true UPKEP_LOG_TO_FILE=true upkep run

# Review the planned actions
cat ~/.upkep/upkep.log
```

**Module-specific troubleshooting:**
Log messages include context information to help identify which module generated each message:

```
[2025-01-22 10:30:15] [INFO] [apt_update] Starting APT package updates
[2025-01-22 10:30:20] [ERROR] [snap_update] Failed to refresh snap packages
```

## Project Structure

```
upkep/
├── scripts/
│   ├── core/                 # Core system components
│   │   ├── config.sh        # Configuration management
│   │   ├── module_loader.sh # Dynamic module loading
│   │   ├── state.sh         # State management
│   │   ├── cli.sh           # Command-line interface
│   │   ├── utils.sh         # Utility functions
│   │   └── prompt_generator.sh # AI prompt generation
│   ├── modules/
│   │   ├── core/            # Built-in modules
│   │   └── user/            # User-created modules
│   └── upkep.sh            # Main executable (built)
├── config/
│   ├── schemas/             # JSON schemas for validation
│   │   ├── module.schema.json
│   │   └── config.schema.json
│   └── templates/           # Module templates
│       ├── basic_module.sh
│       └── advanced_module.sh
├── tests/                   # Test suite
├── docs/                    # Documentation
├── examples/                # Example modules
└── Makefile                # Build system
```

## Core Components

### Configuration Management (`config.sh`)
- YAML-based configuration files
- Global and module-specific settings
- Configuration validation and export
- Default value management

### Module Loader (`module_loader.sh`)
- Dynamic module discovery from multiple paths
- Module validation and registry management
- Category-based organization
- Environment validation

### State Management (`state.sh`)
- Persistent state storage in JSON format
- Module execution tracking
- State reflection for AI integration
- Backup and recovery mechanisms

### CLI Interface (`cli.sh`)
- Intuitive command-line interface
- Subcommand support (run, status, config, etc.)
- Interactive module creation
- Help and documentation

### Utilities (`utils.sh`)
- Enhanced visual formatting with terminal-first design
- Semantic color system with automatic fallbacks
- Dynamic box drawing with Unicode-aware alignment
- Progress indicators and status displays
- System information gathering
- File and directory validation
- Network and connectivity checks

### AI Prompt Generator (`prompt_generator.sh`)
- Contextual AI prompts for module development
- State-based prompt generation
- Template-based prompt creation
- Research integration

## Module System

### Creating a Module

1. **Use a template**:
   ```bash
   upkep create-module my-module --template=basic
   ```

2. **Manual creation**:
   ```bash
   # Copy template
   cp config/templates/basic_module.sh scripts/modules/user/my_module.sh
   
   # Edit the module
   nano scripts/modules/user/my_module.sh
   ```

### Module Structure

Every module must implement:

```bash
# Required function
run_<module_name>() {
    # Main execution logic
}

# Optional functions
get_<module_name>_status() {
    # Status reporting
}

validate_<module_name>_environment() {
    # Environment validation
}
```

### Module Configuration

Modules can be configured via YAML files in `~/.upkep/modules/`:

```yaml
enabled: true
interval_days: 7
timeout: 300
parallel: false
verbose: false
```

## Configuration

upKep uses a **simplified configuration approach** focused on the settings users actually need.

### Quick Start Configuration

The default configuration works immediately with no setup required:

```yaml
# ~/.upkep/config.yaml (created automatically)
# upKep Configuration - Simple Linux system maintenance settings

update_interval: 7          # Days between package updates
cleanup_interval: 30        # Days between cleanup operations
log_level: info             # Logging: error, warn, info, debug
notifications: true         # Show completion notifications
colorblind: false           # Enable colorblind-friendly colors
```

### Configuration Management

```bash
# View current configuration
upkep config show

# Edit configuration in your preferred editor
upkep config edit

# Set individual values
upkep config set log_level debug
upkep config set update_interval 3

# Get specific values
upkep config get update_interval

# Reset to defaults
upkep config reset
```

### Environment Variable Overrides

For testing and temporary changes:

```bash
# Test mode (show what would be done)
UPKEP_DRY_RUN=true upkep run

# Skip interval checks
UPKEP_FORCE=true upkep run

# Temporary debug logging
UPKEP_LOG_LEVEL=debug upkep run

# Override specific intervals
UPKEP_UPDATE_INTERVAL=1 upkep run

# Enable colorblind mode for this session
UPKEP_COLORBLIND=1 upkep run
```

### Advanced Configuration (Legacy)

For users needing complex configurations, the advanced system remains available:

```bash
# Legacy CLI syntax (still supported)
upkep config --show
upkep config --set logging.level=debug
upkep config --export json
```

Advanced YAML structures and module-specific configurations are still supported via the legacy system. See `docs/CONFIGURATION_HYBRID_APPROACH.md` for details.

## Enhanced Visual Design

upKep features a comprehensive terminal-first visual design system inspired by Taskmaster, providing rich, semantic feedback for all operations.

### Visual Features

- **Semantic Color System**: Automatic color detection with fallbacks (24-bit → 256 → 8 → none)
- **Dynamic Box Drawing**: Unicode-aware alignment with automatic width adaptation
- **Status Icons**: Consistent emoji-based status indicators with ASCII fallbacks
- **Progress Indicators**: Enhanced spinners and real-time feedback
- **Responsive Design**: Adapts to terminal size and capabilities
- **Accessibility**: Colorblind-friendly mode with high-contrast colors and text indicators

### Quick Examples

```bash
# Module status display
draw_box "info" "APT UPDATE" \
    "✅ 12 packages updated successfully" \
    "⏰ Execution time: 45 seconds" \
    "📊 Performance: Excellent"

# Error reporting
draw_box "error" "UPDATE FAILED" \
    "❌ Network timeout during download" \
    "🔍 Check internet connection and retry"

# Progress with spinner
spinner $! &
# ... do work ...
kill $spinner_pid 2>/dev/null
echo -e "\r${SUCCESS_GREEN}✔ Success${RESET}"
```

### For Developers

- **Comprehensive Guide**: See `docs/STYLING_SYSTEM_GUIDE.md` for detailed usage
- **Quick Reference**: See `docs/STYLING_QUICK_REFERENCE.md` for common patterns
- **Visual Testing**: Run `bash tests/visual_check.sh` to see all design elements
- **Box Drawing Demo**: Run `bash tests/box_drawing_demo.sh` for interactive examples

## Accessibility

upKep includes comprehensive accessibility features to ensure all users can effectively use the tool.

### Colorblind Mode

For users with color vision deficiencies, upKep provides a colorblind-friendly mode that:

- **Uses high-contrast colors**: Bright green, pure red, golden yellow, and bright blue
- **Adds text indicators**: `[SUCCESS]`, `[ERROR]`, `[WARNING]`, `[INFO]` alongside colors
- **Maintains emoji indicators**: Additional visual cues beyond color alone
- **Works with all terminals**: Automatic detection and fallback support

#### Activating Colorblind Mode

**Method 1: Command-line flag (immediate use)**
```bash
# Enable for this session
upkep --colorblind
upkep -c

# Disable for this session
upkep --no-colorblind
```

**Method 2: Subcommand (persistent setting)**
```bash
# Enable permanently
upkep colorblind on

# Disable permanently
upkep colorblind off

# Check current status
upkep colorblind status

# Get help
upkep colorblind help
```

**Method 3: Environment variable (session-only)**
```bash
# Enable for current session
UPKEP_COLORBLIND=1 upkep run

# Disable for current session
unset UPKEP_COLORBLIND
```

#### What Changes in Colorblind Mode

When colorblind mode is enabled:
- **Success indicators**: Bright green (`#00d700`) with `[SUCCESS]` text
- **Error indicators**: Pure red (`#ff0000`) with `[ERROR]` text  
- **Warning indicators**: Golden yellow (`#ffd700`) with `[WARNING]` text
- **Info indicators**: Bright blue (`#0087ff`) with `[INFO]` text

The mode automatically saves your preference to the configuration file for future sessions.

## CLI Commands

### Core Commands

- `upkep run [options]` - Execute maintenance operations
- `upkep status [options]` - Show current status
- `upkep config [command]` - Manage configuration (simplified)
- `upkep list-modules [options]` - List available modules
- `upkep colorblind [action]` - Manage colorblind accessibility mode

### Configuration Commands

```bash
# Simple configuration management
upkep config show           # Display current settings
upkep config edit           # Edit in $EDITOR
upkep config reset          # Restore defaults
upkep config get <key>      # Get specific setting
upkep config set <key> <value>  # Set specific setting

# Legacy configuration (still supported)
upkep config --show         # Legacy syntax
upkep config --set <key>=<value>
upkep config --get <key>
```

### Module Management

- `upkep create-module <name> [options]` - Create a new module
- `upkep validate-module <name>` - Validate a module
- `upkep test-module <name>` - Test a module

### Development

- `upkep help` - Show help information
- `upkep version` - Show version information

## Development

### Building

```bash
# Build the project
make build

# Run tests
make test

# Lint code
make lint

# Full development workflow
make dev
```

### Testing

```bash
# Run all tests
make test-all

# Run specific test categories
make test          # Unit tests
make test-visual   # Visual check tests
```

### Dependencies

Optional dependencies for enhanced functionality:

- `shellcheck` - Shell script linting
- `jq` - JSON processing
- `yamllint` - YAML validation
- `yq` - YAML/JSON conversion

Install on Ubuntu/Debian:
```bash
sudo apt install shellcheck jq yamllint
```

### Creating Custom Modules

1. **Choose a template**:
   - `basic_module.sh` - Simple modules
   - `advanced_module.sh` - Full-featured modules

2. **Customize the template**:
   - Replace placeholder variables
   - Implement your logic
   - Add error handling

3. **Test your module**:
   ```bash
   upkep validate-module my-module
   upkep test-module my-module
   ```

## State Management

upKep maintains state in `~/.upkep/state.json`:

```json
{
  "version": "2.0.0",
  "last_updated": "2024-01-01T12:00:00Z",
  "modules": {
    "apt_update": {
      "name": "apt_update",
      "last_run": "2024-01-01T12:00:00Z",
      "status": "success",
      "duration": 45,
      "message": "Updated 15 packages"
    }
  },
  "global": {
    "script_last_run": "2024-01-01T12:00:00Z",
    "total_execution_time": 120,
    "modules_executed": 3,
    "modules_skipped": 1,
    "modules_failed": 0
  }
}
```

## Logging

Logs are stored in `~/.upkep/logs/` with rotation:

- `upkep.log` - Main application log
- `upkep.log.1`, `upkep.log.2`, etc. - Rotated logs
- Module-specific logs in `~/.upkep/logs/modules/`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the full test suite
6. Submit a pull request

### Development Guidelines

- Follow shell scripting best practices
- Use the provided templates for new modules
- Add comprehensive error handling
- Include tests for new functionality
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: See the `docs/` directory
- **Issues**: Report bugs and feature requests on GitHub
- **Discussions**: Use GitHub Discussions for questions and ideas

## Roadmap

- [ ] Web interface for monitoring
- [ ] Plugin system for external integrations
- [ ] Machine learning for intelligent scheduling
- [ ] Cloud synchronization of state
- [ ] Mobile app for notifications
- [ ] Integration with systemd timers
- [ ] Support for other Unix-like systems

## Acknowledgments

- Inspired by various system maintenance tools
- Built with modern shell scripting practices
- Designed for extensibility and maintainability 