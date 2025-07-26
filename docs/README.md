# upKep Documentation

**upKep** is a modular, system-wide Linux maintenance and update manager designed to automate essential system upkeep tasks, including APT, Snap, and Flatpak updates, as well as cleanup operations.

## Quick Start

### Installation & Setup
```bash
# Clone the repository
git clone <repository-url>
cd upkep

# Build and install
make build install

# Or run directly
./scripts/main.sh
```

### Basic Usage
```bash
# Run all maintenance tasks
upkep run

# Check status without making changes
upkep status

# Force run all tasks (skip interval checks)
UPKEP_FORCE=true upkep run

# Show help
upkep help
```

## Documentation Structure

### 📋 **Core Documentation**
- **[PRD.md](PRD.md)** - Product Requirements Document (definitive specification)
- **[PROJECT_NOTES.md](PROJECT_NOTES.md)** - Current project status and roadmap
- **[DESIGN.md](DESIGN.md)** - UI/UX design specifications and visual guidelines

### ⚙️ **Configuration**
- **[CONFIGURATION/CONFIGURATION_SYSTEM_REFERENCE.md](CONFIGURATION/CONFIGURATION_SYSTEM_REFERENCE.md)** - Comprehensive configuration system reference (current)
- **[CONFIGURATION/INTERVALS.md](CONFIGURATION/INTERVALS.md)** - Maintenance interval recommendations and best practices

### 🛠️ **Development**
- **[DEVELOPMENT/TASK_EXECUTION_PROMPT.md](DEVELOPMENT/TASK_EXECUTION_PROMPT.md)** - Development workflow and quality standards
- **[DEVELOPMENT/MODULAR_SYSTEM_GUIDE.md](DEVELOPMENT/MODULAR_SYSTEM_GUIDE.md)** - Guide to developing new modules
- **[DEVELOPMENT/MODULAR_SYSTEM_IMPLEMENTATION.md](DEVELOPMENT/MODULAR_SYSTEM_IMPLEMENTATION.md)** - Detailed implementation guide for the modular system

### 🎨 **Styling & UI**
- **[STYLING/STYLING_SYSTEM_GUIDE.md](STYLING/STYLING_SYSTEM_GUIDE.md)** - Comprehensive styling system guide
- **[STYLING/STYLING_QUICK_REFERENCE.md](STYLING/STYLING_QUICK_REFERENCE.md)** - Quick reference for common styling tasks
- **[STYLING/BOX_DRAWING_EXPLANATION.md](STYLING/BOX_DRAWING_EXPLANATION.md)** - Technical reference for box drawing system

## Project Overview

### What is upKep?
upKep is a Linux system maintenance script that automates routine package updates and cleanup tasks. It centralizes updates across APT, Snap, and Flatpak package managers, while tracking the last execution times to avoid unnecessary operations.

### Key Features
- **Modular Architecture**: Easy to extend with new maintenance modules
- **State Tracking**: Prevents redundant operations with intelligent interval checking
- **Multiple Package Managers**: Supports APT, Snap, and Flatpak updates
- **Clean Output**: Beautiful, structured terminal output with progress indicators
- **Accessibility**: Colorblind-friendly mode with high-contrast colors and text indicators
- **Simple Configuration**: Minimal setup with sensible defaults

### Core Principles
- **Simplicity**: Prefer straightforward solutions over clever ones
- **User-Focus**: Focus on what users actually need in their daily workflows
- **Maintainability**: Code should be easy to read, understand, and modify
- **Reliability**: Minimize potential failure points and edge cases

## Project Structure

```
upKep/
├── scripts/
│   ├── main.sh                 # Main entry point
│   ├── modules/
│   │   ├── core/              # Core maintenance modules
│   │   │   ├── apt_update.sh
│   │   │   ├── snap_update.sh
│   │   │   ├── flatpak_update.sh
│   │   │   └── cleanup.sh
│   │   └── user/              # User-created modules
│   └── upkep.sh               # Concatenated single-file version
├── tests/
│   ├── test_runner.sh         # Test execution
│   └── test_cases/            # Individual test modules
├── docs/                      # Documentation
├── logs/                      # Execution logs
└── Makefile                   # Build and execution management
```

## Development Workflow

### Running Tests
```bash
# Run all tests
make test

# Run specific test file
./tests/test_runner.sh test_cases/test_specific.sh
```

### Building
```bash
# Build single-file version
make build

# Clean logs
make clean
```

### Adding New Modules
1. Create module in `scripts/modules/core/` or `scripts/modules/user/`
2. Follow the module template and naming conventions
3. Add corresponding tests in `tests/test_cases/`
4. Update `tests/test_runner.sh` if adding new test files

## Configuration

upKep uses a simplified configuration system. See the [Configuration Reference](CONFIGURATION/CONFIGURATION_SYSTEM_REFERENCE.md) for complete details.

#### Simple Configuration (Recommended)
```yaml
# ~/.upkep/config.yaml
update_interval: 7          # Days between package updates
cleanup_interval: 30        # Days between cleanup operations
log_level: info             # Logging level
notifications: true         # Show completion notifications
```

#### Environment Variables
```bash
# Override settings temporarily
UPKEP_DRY_RUN=true          # Test mode
UPKEP_FORCE=true            # Skip interval checks
UPKEP_LOG_LEVEL=debug       # Temporary debug logging
```

## Contributing

### Development Standards
- Follow the [DEVELOPMENT/TASK_EXECUTION_PROMPT.md](DEVELOPMENT/TASK_EXECUTION_PROMPT.md) workflow
- Write tests for all new functionality
- Maintain 100% test pass rate
- Follow existing code patterns and style
- Ensure backward compatibility

### Code Quality
- All tests must pass before marking tasks complete
- Follow the modular system guidelines
- Use the styling system for consistent output
- Document any new features or changes

## Support

For questions, issues, or contributions:
- Check the documentation in this directory
- Review the [PRD.md](PRD.md) for detailed specifications
- Follow the development workflow in [DEVELOPMENT/TASK_EXECUTION_PROMPT.md](DEVELOPMENT/TASK_EXECUTION_PROMPT.md)

---

**upKep** - Simple, reliable Linux system maintenance.
