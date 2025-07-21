# upKep - Linux System Maintenance Tool
## Product Requirements Document (PRD)

---

## 1. Executive Summary

**upKep** is a modular, system-wide Linux maintenance and update manager designed to automate essential system upkeep tasks. It provides a unified command-line interface for managing APT, Snap, and Flatpak updates, along with system cleanup operations.

### Key Features
- **Unified Maintenance**: Single command to run all system maintenance tasks
- **State Tracking**: Prevents redundant operations through intelligent state management
- **Interval-Based Execution**: Configurable intervals to prevent excessive updates
- **Modular Architecture**: Extensible design for custom maintenance modules
- **Visual Feedback**: Rich CLI output with styled summaries and progress indicators
- **Test-Driven Development**: Comprehensive test suite for reliability

---

## 2. Problem Statement

Linux system maintenance involves managing multiple package managers (APT, Snap, Flatpak) and cleanup routines, which requires:
- Remembering multiple commands
- Manual tracking of when updates were last run
- Time-consuming repetitive tasks
- Risk of forgetting essential maintenance steps
- Potential for excessive updates that waste system resources

**upKep** solves these problems by providing a single, intelligent interface that automates and tracks all maintenance operations with configurable intervals.

---

## 3. Target Users

### Primary Users
- **Linux System Administrators**: Managing multiple systems efficiently
- **Power Users**: Wanting automated system maintenance
- **Developers**: Focused on development, not system upkeep

### Secondary Users
- **Home Users**: Seeking simplified Linux maintenance
- **DevOps Engineers**: Automating system maintenance in CI/CD pipelines

---

## 4. Core Requirements

### 4.1 Functional Requirements

#### FR-1: Package Manager Updates
- **FR-1.1**: Execute APT updates (`apt update && apt upgrade -y`)
- **FR-1.2**: Execute Snap updates (`snap refresh`)
- **FR-1.3**: Execute Flatpak updates (`flatpak update`)
- **FR-1.4**: Handle update failures gracefully with error reporting

#### FR-2: System Cleanup
- **FR-2.1**: Remove unused packages (`apt autoremove -y`)
- **FR-2.2**: Clean package cache (`apt clean`)
- **FR-2.3**: Extensible for additional cleanup operations

#### FR-3: State Management
- **FR-3.1**: Track last run timestamps for each operation type
- **FR-3.2**: Store state in user's home directory (`~/.upkep_state`)
- **FR-3.3**: Display time since last operations
- **FR-3.4**: Support interval-based execution to prevent excessive updates

#### FR-4: Interval Management
- **FR-4.1**: Configurable update interval (default: 7 days)
- **FR-4.2**: Configurable cleanup interval (default: 3 days)
- **FR-4.3**: Skip operations when within configured intervals
- **FR-4.4**: Display clear skip messages with interval information

#### FR-5: User Interface
- **FR-5.1**: Provide visual progress indicators during operations
- **FR-5.2**: Display styled summary boxes for each operation
- **FR-5.3**: Show comprehensive final summary with status indicators
- **FR-5.4**: Support ASCII art branding and clear section headers
- **FR-5.5**: Color-coded status display (green=success, red=failed, yellow=skipped)

#### FR-6: Logging
- **FR-6.1**: Log all operations to `logs/run.log`
- **FR-6.2**: Maintain individual module logs in `logs/modules/`
- **FR-6.3**: Include timestamps and operation results

### 4.2 Non-Functional Requirements

#### NFR-1: Performance
- **NFR-1.1**: Complete all operations within reasonable time limits
- **NFR-1.2**: Provide real-time progress feedback with spinning indicators
- **NFR-1.3**: Minimize system resource usage during operations

#### NFR-2: Reliability
- **NFR-2.1**: Handle network failures gracefully
- **NFR-2.2**: Continue operation if individual modules fail
- **NFR-2.3**: Provide clear error messages and status reporting
- **NFR-2.4**: Maintain backward compatibility with existing state files

#### NFR-3: Usability
- **NFR-3.1**: Simple, intuitive command-line interface
- **NFR-3.2**: Clear visual feedback and status indicators
- **NFR-3.3**: Comprehensive help and documentation

#### NFR-4: Maintainability
- **NFR-4.1**: Modular architecture for easy extension
- **NFR-4.2**: Comprehensive test coverage
- **NFR-4.3**: Clear code documentation and structure

---

## 5. Technical Architecture

### 5.1 Current Architecture

```
upKep/
├── scripts/
│   ├── main.sh                 # Main entry point with interval logic
│   ├── upkep.sh               # Concatenated single-file version
│   ├── modules/
│   │   ├── utils.sh           # Utility functions and visual formatting
│   │   ├── ascii_art.sh       # Visual branding and ASCII art
│   │   ├── state.sh           # State management and persistence
│   │   ├── apt_update.sh      # APT operations
│   │   ├── snap_update.sh     # Snap operations
│   │   ├── flatpak_update.sh  # Flatpak operations
│   │   └── cleanup.sh         # Cleanup operations
│   └── helpers/
│       └── ascii_to_echo.sh   # ASCII art conversion utilities
├── tests/
│   ├── test_runner.sh         # Test execution framework
│   ├── test_cases/            # Individual test modules
│   │   ├── test_state.sh      # State management tests
│   │   ├── test_interval_logic.sh # Interval checking tests
│   │   ├── test_status_vars.sh # Status variable tests
│   │   ├── test_utils.sh      # Utility function tests
│   │   ├── test_ascii_art.sh  # ASCII art tests
│   │   ├── test_formatting.sh # Visual formatting tests
│   │   ├── test_flags.sh      # Flag handling tests
│   │   ├── test_skip_note.sh  # Skip message tests
│   │   └── test_summary_box.sh # Summary display tests
│   ├── mocks/                 # Mock implementations for testing
│   └── visual_check.sh        # Visual output verification
├── logs/                      # Runtime logs (gitignored)
├── docs/                      # Documentation
├── examples/                  # Usage examples
└── Makefile                   # Build and execution management
```

### 5.2 State Management

**State File Location**: `~/.upkep_state`
**State Variables**:
- `UPDATE_LAST_RUN`: Timestamp of last update operations
- `CLEANUP_LAST_RUN`: Timestamp of last cleanup operations
- `SCRIPT_LAST_RUN`: Timestamp of last script execution

**Status Tracking**:
- `APT_STATUS`: "success", "failed", or "skipped"
- `SNAP_STATUS`: "success", "failed", or "skipped"
- `FLATPAK_STATUS`: "success", "failed", or "skipped"
- `CLEANUP_STATUS`: "success", "failed", or "skipped"
- `SKIP_NOTE`: Optional message explaining why operations were skipped

### 5.3 Interval Configuration

**Default Intervals**:
- `UPDATE_INTERVAL_DAYS=7`: Minimum days between update operations
- `CLEANUP_INTERVAL_DAYS=3`: Minimum days between cleanup operations

**Interval Logic**:
- Operations are skipped if within the configured interval
- Clear skip messages display the interval information
- State is not updated when operations are skipped

### 5.4 Module Interface

Each module must implement:
```bash
run_<module_name>() {
    # Module implementation
    # Update corresponding STATUS variable
    # Handle errors appropriately
    # Call appropriate state update function on success
}
```

---

## 6. User Interface Design

### 6.1 Command-Line Interface

**Primary Commands**:
- `make run`: Development execution (runs main.sh)
- `make build`: Create single-file version (upkep.sh)
- `make test`: Run test suite
- `make clean`: Remove logs

**Output Structure**:
1. ASCII art title and branding
2. Current status display (time since last operations)
3. Individual operation sections with progress indicators
4. Skip messages for operations within intervals
5. Comprehensive summary with status indicators

### 6.2 Visual Elements

**Color Scheme**:
- Green: Success operations and progress completion
- Blue: Information displays and status boxes
- Yellow: Warnings, notes, and skipped operations
- Red: Errors and failures
- Magenta: Progress indicators and summary headers
- White: Primary text content

**Box Drawing**: Unicode box characters for structured output
**Progress Indicators**: Spinning indicators during long operations
**Status Indicators**: Color-coded status display in summary

---

## 7. Testing Strategy

### 7.1 Test Categories

**Unit Tests**:
- Individual module functionality
- Utility function behavior
- State management operations
- Visual formatting functions
- Interval logic validation
- Status variable handling

**Integration Tests**:
- Module interaction
- State persistence
- Logging functionality
- Error handling

**System Tests**:
- End-to-end execution
- Real package manager operations (with mocks)
- Performance under various conditions

### 7.2 Test Execution

**Command**: `make test`
**Test Runner**: `tests/test_runner.sh`
**Mock Support**: `tests/mocks/` for isolated testing
**Visual Verification**: `tests/visual_check.sh` for output validation

**Test Coverage**:
- State management (`test_state.sh`)
- Interval logic (`test_interval_logic.sh`)
- Status variables (`test_status_vars.sh`)
- Utility functions (`test_utils.sh`)
- ASCII art (`test_ascii_art.sh`)
- Visual formatting (`test_formatting.sh`)
- Flag handling (`test_flags.sh`)
- Skip messages (`test_skip_note.sh`)
- Summary display (`test_summary_box.sh`)

---

## 8. Development Workflow

### 8.1 Build Process

**Development**: `make run` (executes main.sh)
**Production**: `make build` (creates upkep.sh single-file version)
**Testing**: `make test` (runs test suite)
**Cleanup**: `make clean` (removes logs)

### 8.2 Module Development

1. Create new module in `scripts/modules/`
2. Implement required interface
3. Add tests in `tests/test_cases/`
4. Update main.sh to include new module
5. Verify functionality and update documentation

### 8.3 Version Control

**Ignored Files**:
- State files (`~/.upkep_state`)
- Log files (`logs/`)
- Build artifacts (`scripts/upkep.sh`)
- IDE and OS-specific files

---

## 9. Future Roadmap

### 9.1 Phase 1: Enhanced Modularity
- Dynamic module loading system
- Module discovery and registration
- Metadata-driven module configuration
- Plugin architecture for custom modules

### 9.2 Phase 2: Advanced Features
- Configuration file support for intervals and settings
- Advanced state management with JSON
- Conditional operation execution based on system state
- Notification system for completed operations

### 9.3 Phase 3: Modern CLI Packaging
- Node.js migration for dynamic capabilities
- NPM package distribution
- Global installation support
- Cross-platform compatibility

### 9.4 Phase 4: Enterprise Features
- Multi-system management
- Centralized logging and monitoring
- Integration with configuration management tools
- API for programmatic access

---

## 10. Success Metrics

### 10.1 Technical Metrics
- **Test Coverage**: >90% for all modules
- **Performance**: Complete operations within 5 minutes
- **Reliability**: <1% failure rate for standard operations
- **Maintainability**: <100 lines per module

### 10.2 User Experience Metrics
- **Ease of Use**: Single command execution
- **Feedback Quality**: Clear status indicators and progress feedback
- **Error Handling**: Informative error messages
- **Documentation**: Comprehensive and up-to-date

---

## 11. Constraints and Assumptions

### 11.1 Technical Constraints
- **Platform**: Linux systems with APT package manager
- **Dependencies**: Bash shell, standard Unix utilities
- **Permissions**: Requires sudo for package operations
- **Network**: Internet connectivity for updates

### 11.2 Design Assumptions
- Users have basic command-line familiarity
- System administrators have sudo privileges
- Package managers are properly configured
- Log files should not be version controlled
- State files are user-specific and should not be shared

---

## 12. Risk Assessment

### 12.1 Technical Risks
- **Package Manager Changes**: APT/Snap/Flatpak API changes
- **Permission Issues**: Sudo requirements and security policies
- **Network Failures**: Update operations requiring internet connectivity
- **State Corruption**: State file corruption or permission issues

### 12.2 Mitigation Strategies
- **Comprehensive Testing**: Regular testing against different distributions
- **Error Handling**: Graceful degradation and clear error reporting
- **State Validation**: Robust state file validation and recovery
- **Documentation**: Clear troubleshooting guides and error resolution

---

## 13. Glossary

- **APT**: Advanced Package Tool, Debian/Ubuntu package manager
- **Snap**: Canonical's universal package format and system
- **Flatpak**: Cross-platform application distribution framework
- **State Management**: Tracking of operation timestamps and results
- **Interval Management**: Time-based operation scheduling to prevent excessive updates
- **Module**: Individual maintenance operation implementation
- **upKep**: The project name, derived from "upkeep" (maintenance)

---

*This PRD serves as the definitive source of truth for the upKep project. All development decisions should align with these requirements and specifications.* 