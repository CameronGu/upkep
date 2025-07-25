# **upKep – Linux System Maintenance Tool**

```
[upKep]
-upKep Linux Maintainer-
by CameronGu
```

---

## **1. Overview**

**upKep** is a modular, system-wide Linux maintenance and update manager designed to automate essential system upkeep tasks, including APT, Snap, and Flatpak updates, as well as cleanup operations. It combines:

* **A modular and test-driven architecture** for maintainability.
* **State tracking** to prevent redundant operations (stored in `~/.upkep_state`).
* **Clear CLI output and logging**, with visually styled summaries.
* **A user-focused design** that prioritizes simplicity and reliability.

---

## **2. Purpose**

**upKep** solves the complexity of managing multiple package managers and cleanup routines by offering:

* A **single unified command** to run all maintenance tasks.
* **Automatic discovery of tasks** through modular architecture.
* **State reflection** and interval-based task skipping.
* **Developer-friendly extensibility** to allow custom modules.

---

## **3. Current State**

* **Core Modules Implemented:** `apt_update.sh`, `snap_update.sh`, `flatpak_update.sh`, and `cleanup.sh`.
* **Logging:** All runs tracked in `logs/run.log`, with individual logs per module.
* **Testing:** Modular test cases for ASCII art, state logic, interval checks, flags, and formatting.
* **Documentation:** Found under `docs/` (PRD, DESIGN, README, etc.).
* **Execution:** Managed with a `Makefile` for `run`, `build`, `test`, and `clean` operations.
* **State Management:** User-specific state stored in `~/.upkep_state` (not version controlled).
* **Configuration:** Simplified hybrid system with 7-line default config for 90% of users.

---

## **4. Execution**

### **Makefile**

```makefile
# Makefile for upKep project

run:
	bash scripts/main.sh

build:
	cat scripts/modules/*.sh scripts/main.sh > scripts/upkep.sh
	chmod +x scripts/upkep.sh

test:
	bash tests/test_runner.sh

clean:
	rm -rf logs/*
```

### **Usage**

* **Run:** `make run`
* **Build (single script):** `make build`
* **Test all modules:** `make test`
* **Clean logs:** `make clean`

---

## **5. Project Structure**

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
│   ├── test_cases/            # Individual test modules
│   └── mocks/                 # Mock implementations
├── logs/
│   ├── run.log               # Main execution log
│   └── modules/              # Per-module logs
├── docs/                     # Documentation (PRD, etc.)
└── Makefile                  # Build and execution management
```

---

## **6. State Management**

**State File Location**: `~/.upkep_state` (user's home directory)

**State Variables**:
- `UPDATE_LAST_RUN`: Timestamp of last update operations
- `CLEANUP_LAST_RUN`: Timestamp of last cleanup operations  
- `SCRIPT_LAST_RUN`: Timestamp of last script execution

**Status Tracking**:
- `APT_STATUS`: "success", "failed", or "skipped"
- `SNAP_STATUS`: "success", "failed", or "skipped"
- `FLATPAK_STATUS`: "success", "failed", or "skipped"
- `CLEANUP_STATUS`: "success", "failed", or "skipped"

---

## **7. Current Roadmap**

The **upKep roadmap** prioritizes modularity, reliability, and user experience within the current Bash-based architecture.

### **7.1 Enhanced Module System**

**Goal:** Improve the current modular architecture for better maintainability and extensibility.

* **Module Discovery**: Implement automatic module discovery and loading
* **Module Metadata**: Standardize module metadata (name, description, dependencies)
* **Module Validation**: Add validation for module structure and requirements
* **Module Documentation**: Generate documentation from module metadata

### **7.2 Configuration System Evolution**

**Goal:** Continue refining the hybrid configuration approach based on user feedback.

* **User Feedback Integration**: Gather feedback on simplified vs legacy configuration usage
* **Feature Consolidation**: Identify opportunities to further simplify the system
* **Migration Path**: Plan potential full migration to unified simple system
* **Documentation Updates**: Keep configuration documentation current

### **7.3 Testing and Quality Assurance**

**Goal:** Maintain and improve the comprehensive testing framework.

* **Test Coverage**: Ensure 100% test coverage for all new features
* **Integration Testing**: Expand integration tests for complex workflows
* **Performance Testing**: Add performance benchmarks for critical operations
* **User Acceptance Testing**: Develop user-focused test scenarios

### **7.4 Documentation and User Experience**

**Goal:** Improve documentation and user experience based on actual usage patterns.

* **User Guides**: Create step-by-step guides for common use cases
* **Troubleshooting**: Develop comprehensive troubleshooting documentation
* **Examples**: Provide real-world examples and use cases
* **Community Feedback**: Establish feedback channels for user input

---

## **8. Key Decisions**

### **8.1 State Management**
- **Decision**: Store state in user's home directory (`~/.upkep_state`)
- **Rationale**: System-wide tool that should persist across installations
- **Implication**: State is user-specific and not version controlled

### **8.2 Architecture**
- **Decision**: Modular Bash architecture focused on simplicity and reliability
- **Rationale**: Leverages existing Unix tools while maintaining user-friendly experience
- **Implication**: Maintains backward compatibility while enabling future enhancements

### **8.3 Testing Strategy**
- **Decision**: Comprehensive test suite with mock support
- **Rationale**: Ensures reliability for system maintenance operations
- **Implication**: All new modules must include corresponding tests

### **8.4 Configuration Approach**
- **Decision**: Hybrid configuration system (simple + legacy)
- **Rationale**: Serves both simple use cases (90%) and advanced needs (10%)
- **Implication**: Maintains flexibility while prioritizing simplicity

---

## **9. Success Metrics**

### **9.1 Code Quality**
- **Test Coverage**: Maintain 100% test pass rate
- **Code Complexity**: Keep modules under 200 lines each
- **Documentation**: Ensure all features are documented

### **9.2 User Experience**
- **Setup Time**: <30 seconds for new users
- **Configuration**: <10 lines for 90% of use cases
- **Reliability**: Zero breaking changes for existing users

### **9.3 Maintainability**
- **Module Development**: <1 hour to create new modules
- **Bug Resolution**: <24 hours for critical issues
- **Feature Addition**: <1 week for simple features

---

*For detailed requirements and specifications, see `docs/PRD.md` - the definitive source of truth for the upKep project.*
