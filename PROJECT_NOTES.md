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
* **State tracking** to prevent redundant operations (stored in `~/.auto_maintainer_state`).
* **Clear CLI output and logging**, with visually styled summaries.
* **A future-proof design**, evolving toward dynamic module loading and modern CLI packaging.

---

## **2. Purpose**

**upKep** solves the complexity of managing multiple package managers and cleanup routines by offering:

* A **single unified command** to run all maintenance tasks.
* **Automatic discovery of tasks** (planned via dynamic module loading).
* **State reflection** and interval-based task skipping.
* **Developer-friendly extensibility** to allow custom modules.

---

## **3. Current State**

* **Core Modules Implemented:** `apt_update.sh`, `snap_update.sh`, `flatpak_update.sh`, and `cleanup.sh`.
* **Logging:** All runs tracked in `logs/run.log`, with individual logs per module.
* **Testing:** Modular test cases for ASCII art, state logic, interval checks, flags, and formatting.
* **Documentation:** Found under `docs/` (PRD, CHANGELOG, DESIGN, README).
* **Execution:** Managed with a `Makefile` for `run`, `build`, `test`, and `clean` operations.
* **State Management:** User-specific state stored in `~/.auto_maintainer_state` (not version controlled).

---

## **4. Execution**

### **Makefile**

```makefile
# Makefile for upKep project

run:
	bash scripts/main.sh

build:
	cat scripts/modules/*.sh scripts/main.sh > scripts/update_all.sh
	chmod +x scripts/update_all.sh

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
│   │   ├── utils.sh           # Utility functions
│   │   ├── ascii_art.sh       # Visual branding
│   │   ├── state.sh           # State management
│   │   ├── apt_update.sh      # APT operations
│   │   ├── snap_update.sh     # Snap operations
│   │   ├── flatpak_update.sh  # Flatpak operations
│   │   └── cleanup.sh         # Cleanup operations
│   └── update_all.sh          # Concatenated single-file version
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

**State File Location**: `~/.auto_maintainer_state` (user's home directory)

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

## **7. Roadmap**

The **upKep roadmap** prioritizes modularity, dynamic runtime behavior, and modern CLI packaging.

### **7.1 Dynamic Module Loading**

**Goal:** Transition from concatenated scripts to **dynamic runtime loading** of modules.

* Separate `modules/core/` and `modules/user/`.
* Auto-discover modules via scanning or a registry.
* Use naming conventions like `module_<name>.sh` (or `.js` if migrated).
* Each module will include metadata (`MODULE_NAME`, `DESCRIPTION`, `FLAGS`).
* Implement a loader that imports modules at runtime.

### **7.2 Prompt Generator (Not AI)**

**Goal:** Generate a **deterministic AI prompt template** for building new modules.

* Command: `upkep suggest-prompt`.
* Reads current state (flags, modules).
* Outputs a pre-filled template like:

  ```
  "This project has the following modules and flags: [...]
   Here is an example module template:
   [code snippet]
   I want a new module that [user description here]."
  ```
* Writes template to `prompt_for_new_module.txt`.

### **7.3 Dynamic State Reflection**

**Goal:** Reflect real-time system state for better module generation and documentation.

* Maintain `state.json` (or equivalent) in addition to existing state file.
* Include flags, modules, and capabilities.
* `suggest-prompt` will read from this state to create real-time templates.

### **7.4 Package Feasibility (Node.js vs. Bash)**

* **Why Node.js?**

  * Easier dynamic module loading (`require()`/`import()`).
  * Modern CLI UX libraries (commander, inquirer).
  * Cross-platform packaging via `pkg`.
  * Global install: `npm install -g upkep`.
* **Migration Path:**

  * **Phase 1:** Modularize current Bash scripts.
  * **Phase 2:** Build a Node.js CLI loader for Bash modules.
  * **Phase 3:** Migrate core modules to JavaScript.
  * **Phase 4:** Package as an NPM CLI with optional binaries.

### **7.5 Setup Command**

**Goal:** Help users create custom modules.

* Command: `upkep setup`
* Initializes `modules/user/`.
* Provides `module_template.sh` (or `.js`).
* Optionally validates new modules with `tests/validate_module`.

---

## **8. Roadmap Phases**

### **Phase 1 (Short-Term)**

* Implement a **module loader** for Bash.
* Add `--list-modules` and `--describe <module>`.
* Implement `suggest-prompt` command.

### **Phase 2 (Mid-Term)**

* Migrate state to `state.json` (in addition to existing state file).
* Add a build system (or npm script) to package modules into a standalone CLI.
* Introduce testing for module validation (Jest or equivalent).

### **Phase 3 (Long-Term)**

* Transition fully to Node.js.
* Publish as an NPM package (`npm install -g upkep`).
* Support hybrid Bash/JS user modules.

---

## **9. Key Decisions**

### **9.1 State Management**
- **Decision**: Store state in user's home directory (`~/.auto_maintainer_state`)
- **Rationale**: System-wide tool that should persist across installations
- **Implication**: State is user-specific and not version controlled

### **9.2 Architecture**
- **Decision**: Modular Bash architecture with future Node.js migration path
- **Rationale**: Leverages existing Unix tools while planning for modern CLI capabilities
- **Implication**: Maintains backward compatibility while enabling future enhancements

### **9.3 Testing Strategy**
- **Decision**: Comprehensive test suite with mock support
- **Rationale**: Ensures reliability for system maintenance operations
- **Implication**: All new modules must include corresponding tests

---

*For detailed requirements and specifications, see `docs/PRD.md` - the definitive source of truth for the upKep project.*
