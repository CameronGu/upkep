# upKep - Linux System Maintenance Tool

A modular, extensible system maintenance tool for Linux that automates common maintenance tasks with intelligent scheduling and comprehensive logging.

## Features

- **Modular Architecture**: Dynamic module discovery and loading from multiple paths
- **Intelligent Scheduling**: Interval-based execution with caching to prevent redundant operations
- **Comprehensive Logging**: Multi-level logging with rotation and structured output
- **State Management**: Persistent state tracking for modules and global operations
- **Configuration Management**: YAML-based configuration with validation
- **Visual Interface**: Rich terminal output with progress indicators and status boxes
- **AI Integration**: AI prompt generation for module development
- **Extensible**: Easy to create custom modules with templates

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/upkep.git
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
- Visual formatting and progress indicators
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

### Global Configuration

Located at `~/.upkep/config.yaml`:

```yaml
global:
  log_level: info
  notifications: true
  dry_run: false
  parallel_execution: true
  max_parallel_modules: 4

defaults:
  update_interval: 7
  cleanup_interval: 3
  security_interval: 1

logging:
  file: ~/.upkep/logs/upkep.log
  max_size: 10MB
  max_files: 5
  format: text
```

### Module Configuration

Each module can have its own configuration file:

```yaml
# ~/.upkep/modules/apt_update.yaml
enabled: true
interval_days: 7
timeout: 600
parallel: false
verbose: true
```

## CLI Commands

### Core Commands

- `upkep run [options]` - Execute maintenance operations
- `upkep status [options]` - Show current status
- `upkep config [options]` - Manage configuration
- `upkep list-modules [options]` - List available modules

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