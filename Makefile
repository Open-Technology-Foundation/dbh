# Makefile for dbh project

# Variables
SCRIPT = dbh
TESTS_DIR = tests
SHELLCHECK = shellcheck
TEST_RUNNER = tests/run_tests.sh

# Default target
.PHONY: all
all: lint test

# Lint with shellcheck
.PHONY: lint
lint:
	@echo "Linting $(SCRIPT)..."
	@$(SHELLCHECK) $(SCRIPT) || true

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@cd $(TESTS_DIR) && ./run_tests.sh

# Verbose test run
.PHONY: test-verbose
test-verbose:
	@echo "Running tests with verbose output..."
	@cd $(TESTS_DIR) && ./run_tests.sh --verbose

# Individual test suites
.PHONY: test-basic
test-basic:
	@echo "Running basic tests..."
	@cd $(TESTS_DIR) && ./run_tests.sh test_basic.sh

.PHONY: test-security
test-security:
	@echo "Running security tests..."
	@cd $(TESTS_DIR) && ./run_tests.sh test_security.sh

.PHONY: test-validation
test-validation:
	@echo "Running validation helper tests..."
	@cd $(TESTS_DIR) && ./run_tests.sh test_validation.sh

# Verbose test suites
.PHONY: test-basic-verbose
test-basic-verbose:
	@echo "Running basic tests with verbose output..."
	@cd $(TESTS_DIR) && ./run_tests.sh --verbose test_basic.sh

.PHONY: test-security-verbose
test-security-verbose:
	@echo "Running security tests with verbose output..."
	@cd $(TESTS_DIR) && ./run_tests.sh --verbose test_security.sh

.PHONY: test-validation-verbose
test-validation-verbose:
	@echo "Running validation helper tests with verbose output..."
	@cd $(TESTS_DIR) && ./run_tests.sh --verbose test_validation.sh

# Clean up temporary files
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@find . -name "*~" -delete
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all                  - Run linting and tests (default)"
	@echo "  lint                 - Run shellcheck on the script"
	@echo "  test                 - Run all tests"
	@echo "  test-verbose         - Run all tests with detailed output"
	@echo "  test-basic           - Run basic functionality tests"
	@echo "  test-security        - Run security-focused tests"
	@echo "  test-validation      - Run validation helper tests"
	@echo "  test-basic-verbose   - Run basic tests with detailed output"
	@echo "  test-security-verbose - Run security tests with detailed output"
	@echo "  test-validation-verbose - Run validation helper tests with detailed output"
	@echo "  clean                - Remove temporary files"
	@echo "  help                 - Show this help message"