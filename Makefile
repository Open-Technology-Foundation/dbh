# Makefile for dbh project

# Script and directories
SCRIPT       = dbh
TESTS_DIR    = tests
SHELLCHECK   = shellcheck
TEST_RUNNER  = tests/run_tests.sh

# System-wide installation paths
PREFIX       = /usr/local
BINDIR       = $(PREFIX)/bin
MANDIR       = $(PREFIX)/share/man/man1
COMPDIR      = /usr/share/bash-completion/completions

# User-local installation paths
USER_PREFIX  = $(HOME)/.local
USER_BINDIR  = $(USER_PREFIX)/bin
USER_MANDIR  = $(USER_PREFIX)/share/man/man1
USER_COMPDIR = $(USER_PREFIX)/share/bash-completion/completions
USER_CONFDIR = $(HOME)/.config/dbh

# Source files
COMPLETION   = dbh.bash_completion
MANPAGE      = dbh.1

# Default target
.PHONY: all
all: lint test

# System-wide install (requires sudo)
.PHONY: install
install:
	@echo "Installing $(SCRIPT) system-wide..."
	install -D -m 755 $(SCRIPT) $(DESTDIR)$(BINDIR)/$(SCRIPT)
	install -D -m 644 $(COMPLETION) $(DESTDIR)$(COMPDIR)/$(SCRIPT)
	install -D -m 644 $(MANPAGE) $(DESTDIR)$(MANDIR)/$(MANPAGE)
	@echo "✓ Installed $(SCRIPT) to $(BINDIR)"
	@echo "✓ Installed bash completion to $(COMPDIR)/$(SCRIPT)"
	@echo "✓ Installed manpage to $(MANDIR)/$(MANPAGE)"

# User-local install (no sudo required)
.PHONY: install-user
install-user:
	@echo "Installing $(SCRIPT) for current user..."
	@mkdir -p $(USER_BINDIR)
	install -m 755 $(SCRIPT) $(USER_BINDIR)/$(SCRIPT)
	@mkdir -p $(USER_COMPDIR)
	install -m 644 $(COMPLETION) $(USER_COMPDIR)/$(SCRIPT)
	@mkdir -p $(USER_MANDIR)
	install -m 644 $(MANPAGE) $(USER_MANDIR)/$(MANPAGE)
	@mkdir -p $(USER_CONFDIR)
	@if [ ! -f $(USER_CONFDIR)/config.example ]; then \
		install -m 644 config.example $(USER_CONFDIR)/config.example; \
		echo "✓ Installed config.example to $(USER_CONFDIR)"; \
	fi
	@echo "✓ Installed $(SCRIPT) to $(USER_BINDIR)"
	@echo "✓ Installed bash completion to $(USER_COMPDIR)/$(SCRIPT)"
	@echo "✓ Installed manpage to $(USER_MANDIR)/$(MANPAGE)"
	@case ":$(PATH):" in \
		*:$(USER_BINDIR):*) ;; \
		*) echo ""; echo "▲ Note: Add $(USER_BINDIR) to your PATH if not already present" ;; \
	esac

# System-wide uninstall (requires sudo)
.PHONY: uninstall
uninstall:
	@echo "Removing system-wide $(SCRIPT) installation..."
	rm -f $(DESTDIR)$(BINDIR)/$(SCRIPT)
	rm -f $(DESTDIR)$(COMPDIR)/$(SCRIPT)
	rm -f $(DESTDIR)$(MANDIR)/$(MANPAGE)
	@echo "✓ Removed $(SCRIPT) from $(BINDIR)"
	@echo "✓ Removed bash completion from $(COMPDIR)"
	@echo "✓ Removed manpage from $(MANDIR)"

# User-local uninstall
.PHONY: uninstall-user
uninstall-user:
	@echo "Removing user-local $(SCRIPT) installation..."
	rm -f $(USER_BINDIR)/$(SCRIPT)
	rm -f $(USER_COMPDIR)/$(SCRIPT)
	rm -f $(USER_MANDIR)/$(MANPAGE)
	@echo "✓ Removed $(SCRIPT) from $(USER_BINDIR)"
	@echo "✓ Removed bash completion from $(USER_COMPDIR)"
	@echo "✓ Removed manpage from $(USER_MANDIR)"
	@echo "◉ Note: Config directory $(USER_CONFDIR) preserved"

# Lint with shellcheck
.PHONY: lint
lint:
	@echo "Linting $(SCRIPT)..."
	@$(SHELLCHECK) $(SCRIPT) || true

# Run all tests
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
	@echo ""
	@echo "  Installation:"
	@echo "    install          - System-wide install to $(BINDIR) (requires sudo)"
	@echo "    install-user     - User-local install to $(USER_BINDIR)"
	@echo "    uninstall        - Remove system-wide installation (requires sudo)"
	@echo "    uninstall-user   - Remove user-local installation"
	@echo ""
	@echo "  Development:"
	@echo "    all              - Run linting and tests (default)"
	@echo "    lint             - Run shellcheck on the script"
	@echo "    test             - Run all tests"
	@echo "    test-verbose     - Run all tests with detailed output"
	@echo "    test-basic       - Run basic functionality tests"
	@echo "    test-security    - Run security-focused tests"
	@echo "    test-validation  - Run validation helper tests"
	@echo "    clean            - Remove temporary files"
	@echo "    help             - Show this help message"
