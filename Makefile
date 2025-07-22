# upKep Makefile
# Build, test, and development tasks for upKep

# Variables
PROJECT_NAME = upkep
VERSION = 2.0.0
SCRIPTS_DIR = scripts
CORE_DIR = $(SCRIPTS_DIR)/core
MODULES_DIR = $(SCRIPTS_DIR)/modules
CONFIG_DIR = config
TESTS_DIR = tests
DOCS_DIR = docs
EXAMPLES_DIR = examples

# Shell scripts to lint
SHELL_SCRIPTS = $(shell find $(SCRIPTS_DIR) -name "*.sh" -type f)
TEST_SCRIPTS = $(shell find $(TESTS_DIR) -name "*.sh" -type f)
ALL_SCRIPTS = $(SHELL_SCRIPTS) $(TEST_SCRIPTS)

# Default target
.PHONY: all
all: build

# Build the project
.PHONY: build
build:
	@echo "Building $(PROJECT_NAME) v$(VERSION)..."
	@echo "Creating upkep.sh from core scripts..."
	@cat $(CORE_DIR)/*.sh > $(SCRIPTS_DIR)/upkep.sh
	@chmod +x $(SCRIPTS_DIR)/upkep.sh
	@echo "Build complete: $(SCRIPTS_DIR)/upkep.sh"

# Install upKep to system
.PHONY: install
install: build
	@echo "Installing $(PROJECT_NAME)..."
	@sudo cp $(SCRIPTS_DIR)/upkep.sh /usr/local/bin/upkep
	@sudo chmod +x /usr/local/bin/upkep
	@echo "Installation complete. Run 'upkep --help' to get started."

# Uninstall upKep from system
.PHONY: uninstall
uninstall:
	@echo "Uninstalling $(PROJECT_NAME)..."
	@sudo rm -f /usr/local/bin/upkep
	@echo "Uninstallation complete."

# Run shellcheck on all shell scripts
.PHONY: lint
lint:
	@echo "Running shellcheck on $(words $(ALL_SCRIPTS)) shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(ALL_SCRIPTS) || exit 1; \
		echo "Shellcheck passed for all scripts."; \
	else \
		echo "Warning: shellcheck not found. Install it for linting."; \
		echo "  Ubuntu/Debian: sudo apt install shellcheck"; \
		echo "  macOS: brew install shellcheck"; \
	fi

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@if [ -f "$(TESTS_DIR)/test_runner.sh" ]; then \
		$(TESTS_DIR)/test_runner.sh; \
	else \
		echo "No test runner found."; \
	fi

# Run visual check tests
.PHONY: test-visual
test-visual:
	@echo "Running visual check tests..."
	@if [ -f "$(TESTS_DIR)/visual_check.sh" ]; then \
		$(TESTS_DIR)/visual_check.sh; \
	else \
		echo "No visual check script found."; \
	fi

# Run all tests
.PHONY: test-all
test-all: test test-visual

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -f $(SCRIPTS_DIR)/upkep.sh
	@rm -rf $(SCRIPTS_DIR)/*.tmp
	@echo "Clean complete."

# Deep clean (including logs and state)
.PHONY: clean-all
clean-all: clean
	@echo "Performing deep clean..."
	@rm -rf ~/.upkep/logs/*
	@rm -rf ~/.upkep/cache/*
	@rm -f ~/.upkep/state.json
	@echo "Deep clean complete."

# Show project structure
.PHONY: structure
structure:
	@echo "$(PROJECT_NAME) Project Structure"
	@echo "================================"
	@echo "Scripts:"
	@find $(SCRIPTS_DIR) -type f -name "*.sh" | sort | sed 's/^/  /'
	@echo ""
	@echo "Configuration:"
	@find $(CONFIG_DIR) -type f | sort | sed 's/^/  /'
	@echo ""
	@echo "Tests:"
	@find $(TESTS_DIR) -type f | sort | sed 's/^/  /'
	@echo ""
	@echo "Documentation:"
	@find $(DOCS_DIR) -type f | sort | sed 's/^/  /'

# Show help
.PHONY: help
help:
	@echo "$(PROJECT_NAME) Makefile Help"
	@echo "============================"
	@echo ""
	@echo "Available targets:"
	@echo "  build        - Build the upkep.sh script from core modules"
	@echo "  install      - Install upKep to /usr/local/bin"
	@echo "  uninstall    - Remove upKep from /usr/local/bin"
	@echo "  lint         - Run shellcheck on all shell scripts"
	@echo "  test         - Run unit tests"
	@echo "  test-visual  - Run visual check tests"
	@echo "  test-all     - Run all tests"
	@echo "  clean        - Remove build artifacts"
	@echo "  clean-all    - Deep clean (including logs and state)"
	@echo "  structure    - Show project structure"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build install  - Build and install"
	@echo "  make lint test      - Lint and test"
	@echo "  make clean-all      - Complete cleanup"

# Validate project structure
.PHONY: validate
validate:
	@echo "Validating project structure..."
	@# Check required directories
	@for dir in $(SCRIPTS_DIR) $(CORE_DIR) $(MODULES_DIR) $(CONFIG_DIR) $(TESTS_DIR) $(DOCS_DIR); do \
		if [ ! -d "$$dir" ]; then \
			echo "Error: Required directory '$$dir' not found"; \
			exit 1; \
		fi; \
	done
	@# Check required core files
	@for file in config.sh module_loader.sh state.sh cli.sh utils.sh prompt_generator.sh; do \
		if [ ! -f "$(CORE_DIR)/$$file" ]; then \
			echo "Error: Required core file '$(CORE_DIR)/$$file' not found"; \
			exit 1; \
		fi; \
	done
	@# Check configuration schemas
	@for schema in module.schema.json config.schema.json; do \
		if [ ! -f "$(CONFIG_DIR)/schemas/$$schema" ]; then \
			echo "Error: Required schema '$(CONFIG_DIR)/schemas/$$schema' not found"; \
			exit 1; \
		fi; \
	done
	@# Check templates
	@for template in basic_module.sh advanced_module.sh; do \
		if [ ! -f "$(CONFIG_DIR)/templates/$$template" ]; then \
			echo "Error: Required template '$(CONFIG_DIR)/templates/$$template' not found"; \
			exit 1; \
		fi; \
	done
	@echo "Project structure validation passed."

# Check dependencies
.PHONY: check-deps
check-deps:
	@echo "Checking dependencies..."
	@# Check for shellcheck
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "✓ shellcheck found"; \
	else \
		echo "✗ shellcheck not found (optional for linting)"; \
	fi
	@# Check for jq
	@if command -v jq >/dev/null 2>&1; then \
		echo "✓ jq found"; \
	else \
		echo "✗ jq not found (optional for JSON processing)"; \
	fi
	@# Check for yamllint
	@if command -v yamllint >/dev/null 2>&1; then \
		echo "✓ yamllint found"; \
	else \
		echo "✗ yamllint not found (optional for YAML validation)"; \
	fi
	@# Check for yq
	@if command -v yq >/dev/null 2>&1; then \
		echo "✓ yq found"; \
	else \
		echo "✗ yq not found (optional for YAML/JSON conversion)"; \
	fi

# Development workflow
.PHONY: dev
dev: validate lint test-all

# Release preparation
.PHONY: release
release: clean validate lint test-all build
	@echo "Release preparation complete."
	@echo "Version: $(VERSION)"
	@echo "Ready for release."

# Default target
.DEFAULT_GOAL := help
