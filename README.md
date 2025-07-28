# upKep Linux Maintainer - Simple v1.0 (ARCHIVED)

> **⚠️ ARCHIVE BRANCH** - This is the original simple implementation of upKep. For the current improved version, see the `main` branch.

## Overview

This branch contains the original, simple implementation of **upKep** (Linux Maintainer), a straightforward bash script for automating routine Linux system maintenance tasks. This version represents the initial working implementation that was later enhanced with more advanced features.

## What This Version Includes

### Core Features
- **APT Package Updates** - Updates system packages via apt
- **Snap Package Updates** - Updates snap packages
- **Flatpak Updates** - Updates flatpak applications
- **System Cleanup** - Removes unnecessary packages and cache
- **Interval Management** - Prevents excessive updates with configurable intervals
- **Status Tracking** - Tracks when operations were last performed

### Simple Architecture
- **Monolithic Design** - All functionality in a single main script
- **Basic Module System** - Simple source-based module loading
- **Straightforward State Management** - Basic timestamp tracking
- **Minimal Dependencies** - Only requires bash and standard Linux tools

## Quick Start

```bash
# Run the maintainer
make run

# Or directly
bash scripts/main.sh

# Build standalone script
make build

# Run tests
make test
```

## Configuration

### Intervals (in main.sh)
```bash
UPDATE_INTERVAL_DAYS=7      # Minimum days between updates
CLEANUP_INTERVAL_DAYS=3     # Minimum days between cleanups
```

### State Management
- State is stored in `logs/state.txt`
- Tracks last run timestamps for each operation
- Prevents excessive system maintenance

## File Structure

```
scripts/
├── main.sh              # Main entry point
├── modules/
│   ├── apt_update.sh    # APT package updates
│   ├── snap_update.sh   # Snap package updates
│   ├── flatpak_update.sh # Flatpak updates
│   ├── cleanup.sh       # System cleanup
│   ├── state.sh         # State management
│   ├── utils.sh         # Utility functions
│   └── ascii_art.sh     # ASCII art and display
├── helpers/             # Helper scripts
└── upkep.sh            # Built standalone script

tests/                   # Test suite
docs/                    # Documentation
logs/                    # Log files and state
```

## Why This Version Was Archived

This simple implementation was archived to preserve the original working version while the project evolved with:

- **Enhanced modularity** - More sophisticated module system
- **Advanced configuration** - YAML-based configuration
- **Improved styling** - Better visual presentation
- **Extended functionality** - Additional maintenance features
- **Better error handling** - More robust operation

## Migration to Current Version

To use the current improved version:

```bash
git checkout main
```

The current version maintains backward compatibility while adding significant improvements in functionality, maintainability, and user experience.

## Support

This archived version is preserved for:
- **Reference** - Understanding the original implementation
- **Rollback** - If needed for compatibility reasons
- **Learning** - Simple example of the core concepts

For active development and new features, please use the `main` branch.

---

**Branch Info:** `archive/simple-v1`  
**Status:** Archived (Read-only)  
**Last Updated:** Preserved as of branch creation