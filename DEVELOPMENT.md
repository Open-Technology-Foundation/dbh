# Development Guide for dbh

This document provides comprehensive information for developers who want to understand, modify, or contribute to the dbh MySQL database helper utility.

## Table of Contents

- [Project Overview](#project-overview)
  - [Core Architecture](#core-architecture)
  - [Key Components](#key-components)
- [Development Environment](#development-environment)
  - [Tech Stack](#tech-stack)
  - [Development Setup](#development-setup)
- [Coding Principles](#coding-principles)
  - [Core Philosophy](#core-philosophy)
  - [Code Style](#code-style)
  - [Security Principles](#security-principles)
- [Testing](#testing)
  - [Automated Testing](#automated-testing)
  - [Manual Testing](#manual-testing)
- [Implementation Details](#implementation-details)
  - [Key Files](#key-files)
  - [Directory Structure](#directory-structure)
  - [Critical Functions](#critical-functions)
  - [Adding a New Command](#adding-a-new-command)
  - [State Management](#state-management)
  - [Error Handling](#error-handling)
  - [Security Implementation](#security-implementation)
- [Feature Roadmap](#feature-roadmap)
- [Contributing](#contributing)
  - [Contribution Workflow](#contribution-workflow)
  - [Commit Guidelines](#commit-guidelines)
  - [Pull Request Process](#pull-request-process)
- [License](#license)

## Project Overview

The `dbh` script is a MySQL database helper utility (version 3.7.1) designed to provide a fast, interactive way to explore and query MySQL databases. It's written entirely in Bash and interfaces with the MySQL command-line client to provide an enhanced user experience.

### Core Architecture

The script is organized into several functional sections that work together to provide a cohesive interface:

1. **Configuration & Initialization** (Lines ~30-100)
   - Environment setup
   - Config file loading
   - Command-line argument parsing
   - History management

2. **Helper Functions** (Lines ~100-400)
   - Message formatting (info, error, warning, etc.)
   - SQL escaping and security
   - Temporary file handling
   - MySQL execution wrappers

3. **Database Context Management** (Lines ~400-550)
   - Functions to manage and track database selection
   - Functions to manage and track table selection
   - Context validation helpers

4. **Command Handlers** (Lines ~800+)
   - Individual functions for each `/command` operation
   - Each handler follows a consistent pattern
   - Functions prefixed with `handle_cmd_*`

5. **Main Execution Loop** (Near end of file)
   - Command input processing
   - Command dispatching
   - Shell execution handling
   - Direct SQL execution

### Key Components

#### Command Processing System

- **Command Types**:
  - Slash commands (`/help`, `/databases`, etc.) for database operations
  - Bang commands (`!ls`, `!`) for system operations
  - Direct SQL execution for any input not starting with `/` or `!`
  - Command history recall with `!number` syntax

- **Command Handlers**: Functions named `handle_cmd_*` that implement specific operations.
  - Each handler is responsible for one command
  - Handlers verify appropriate context
  - Return values indicate success (0) or failure (non-zero)
  - Commands report errors through the `error()` function

#### Navigation System

- **Hierarchical Navigation**:
  - Users navigate from top level → database → table
  - Context-aware prompt showing the current selection
  - Back navigation with `/..`, `/0`, or `/back`

- **Context Management**:
  - Global variables track current database and table selections
  - `set_database_context()` and `set_table_context()` manage transitions
  - Context validation helpers enforce prerequisites

#### Query Building

- **Component-by-component Query Construction**:
  - State variables track query components
  - Interactive column selection menus
  - WHERE, ORDER BY, and LIMIT clause management
  - Query execution only combines components when requested

## Development Environment

### Tech Stack

- **Required**:
  - Ubuntu 24.04.2 or compatible Linux distribution
  - Bash 5.2.21+
  - MySQL 8.0.41+
  - GNU coreutils (for standard command-line utilities)

- **Development Tools**:
  - Shellcheck (for static analysis)
  - Make (for running tests and build tasks)
  - Git (for version control)

### Development Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Open-Technology-Foundation/dbh.git
   cd dbh
   ```

2. **Set up development environment**:
   ```bash
   chmod +x dbh
   # Configure MySQL access for testing
   cp ~/.mylocalhost.cnf ~/.mylocalhost.dev.cnf
   # Edit the dev config file with test database credentials
   ```

3. **Run linting**:
   ```bash
   shellcheck dbh
   # Or using make
   make lint
   ```

4. **Run tests**:
   ```bash
   # Run all tests
   make test
   
   # Run specific test suites
   make test-basic
   make test-security
   ```

## Coding Principles

### Core Philosophy

The dbh project follows several key philosophical principles that guide development:

- **K.I.S.S. (Keep It Simple, Stupid)** - Focus on simplicity and readability over complex features
- **"The best process is no process"** - Minimize unnecessary complexity and bureaucracy
- **"Everything should be made as simple as possible, but not simpler."** - Balance simplicity with required functionality
- **Security by design** - Security considerations are built into the architecture from the beginning
- **Progressive enhancement** - Core features work well, with advanced features building on top

### Code Style

All shell scripts should follow these guidelines:

- **Bash Shebang**: `#!/usr/bin/env bash`
- **Error Handling**: `set -euo pipefail` at start for robust error handling
- **Indentation**: 2-space indentation throughout
- **Variable Declarations**: Use `declare` statements with appropriate flags
  - Integer values with `-i` flag
  - Exported variables with `-x` flag
  - Global variables with `-g` flag
  - Arrays with `-a` flag
- **Conditionals**: Use `[[` over `[` for conditionals
- **Simple Conditions**: Prefer `((...)) && ...` or `[[...]] && ...` over `if...then` for simple conditions
- **Script Termination**: Always end scripts with '\n#fin\n'
- **Static Analysis**: Use shellcheck for validation (disable specific rules when necessary with comments)
- **Naming**:
  - Functions: Use lowercase with underscores (snake_case)
  - Local variables: Use lowercase with underscores
  - Global variables: Use CamelCase or UPPER_CASE
  - Constants: Use UPPER_CASE
- **Function Documentation**:
  - Add a brief description of what the function does
  - Document parameters and return values
  - Mention side effects if any
- **Section Headers**: Use comment blocks to separate logical sections:
   ```bash
   # --- Section Name ---
   ```
- **Exit Codes**: Use consistent exit codes for error conditions
  - 0: Success
  - 1: General error
  - 2: Invalid argument or usage
  - 3: MySQL connection/execution error

### Security Principles

Security is a critical aspect of the dbh utility, especially since it interacts with databases. Always adhere to these principles:

- **SQL Injection Prevention**:
  - Use the `quote_ident()` and `escape_sql_value()` functions for ALL user inputs
  - NEVER concatenate raw user input directly into SQL queries
  - Validate numeric inputs with regex where appropriate
  - Use command-line arguments securely

- **Temporary File Security**:
  - Use `create_secure_tempfile()` for all temporary files
  - Set appropriate permissions (0600)
  - Clean up properly with traps
  - Use secure creation patterns

- **Error Handling**:
  - Report errors clearly but don't expose sensitive information
  - Use error codes consistently
  - Ensure secure failure modes
  - Validate inputs before use

- **Credential Management**:
  - Never include hardcoded credentials
  - Use MySQL configuration files
  - Protect credential files with appropriate permissions

## Testing

The dbh project includes both automated and manual testing approaches to ensure code quality and correctness.

### Automated Testing

The project includes a test suite in the `tests/` directory. You can run the tests using:

```bash
# Run all tests
make test

# Run specific test suites
make test-basic
make test-security
make test-validation

# Run with verbose output
make test-verbose
```

The test suite includes:

1. **Basic Functionality Tests** (`test_basic.sh`):
   - Command-line options
   - Help and version display
   - Profile path handling
   - Path resolution functions

2. **Security Tests** (`test_security.sh`):
   - SQL escaping functions
   - Path handling and resolution
   - Secure temporary file creation
   - SQL injection prevention

3. **Validation Helper Tests** (`test_validation.sh`):
   - Database and table context validation
   - Input validation helpers
   - Error reporting consistency

### Manual Testing

Due to the interactive nature of dbh, several aspects need manual testing that cannot be easily automated:

1. **Interactive Functionality Testing**:
   - Run `./dbh -h` to verify help output
   - Connect to test database: `./dbh testdb`
   - Navigate through databases and tables
   - Execute basic SQL queries

2. **Command Testing**:
   - Test each `/command` with valid and invalid inputs
   - Verify correct output formatting
   - Check error handling with intentionally invalid inputs

3. **Security Testing**:
   - Test with SQL injection attempts
   - Verify secure handling of credentials
   - Check temporary file permissions

4. **Shell Integration Testing**:
   - Test shell command execution
   - Verify context is maintained after shell operations
   - Check security of shell execution

## Implementation Details

### Key Files

- `dbh` - The main script file containing all functionality
- `config.example` - Example configuration template
- `README.md` - User documentation
- `DEVELOPMENT.md` - Developer documentation (this file)
- `USAGE.md` - Detailed usage examples
- `tests/` - Directory containing test scripts
  - `run_tests.sh` - Test runner script
  - `test_basic.sh` - Basic functionality tests
  - `test_security.sh` - Security-focused tests
  - `test_validation.sh` - Context validation tests
  - `test_framework.sh` - Testing framework utilities

### Directory Structure

```
/
├── dbh                 # Main executable script
├── config.example      # Example configuration file
├── README.md           # User documentation
├── DEVELOPMENT.md      # Developer documentation
├── PURPOSE-FUNCTIONALITY-USAGE.md  # Detailed usage documentation
├── USAGE.md            # Usage examples
├── LICENSE             # GPL-3.0 license file
├── Makefile            # Build and test automation
└── tests/              # Test suite
    ├── run_tests.sh    # Test runner
    ├── test_basic.sh   # Basic functionality tests
    ├── test_framework.sh  # Testing framework
    ├── test_security.sh   # Security tests
    └── test_validation.sh # Context validation tests
```

### Critical Functions

Here are some of the most important functions in the codebase:

- **Core Flow**:
  - `main()` - Entry point and main execution loop
  - `handle_cmd_*()` - Command handler functions for each operation

- **MySQL Interaction**:
  - `mysql_exec()` - Secure MySQL command execution wrapper
  - `mysql_run_display()` - MySQL execution for interactive display

- **Security**:
  - `quote_ident()` - SQL identifier quoting for security
  - `escape_sql_value()` - SQL value escaping for security
  - `create_secure_tempfile()` - Secure temporary file creation

- **Context Management**:
  - `set_database_context()` - Manage database selection state
  - `set_table_context()` - Manage table selection state
  - `require_database()` - Validate database context
  - `require_table()` - Validate table context

- **Utility**:
  - `info()`, `error()`, `warn()`, `success()` - Messaging functions
  - `load_config()` - Configuration loading
  - `load_history()`, `save_history()` - History management

### Adding a New Command

To add a new command to dbh, follow these steps:

1. **Create a handler function**:
   ```bash
   handle_cmd_newcommand() {
     # Validate context requirements
     if [[ -z "$Database" ]]; then
       error "No database selected. Use /database first."
       return 1
     fi
     
     # Implement command functionality
     local arg="$*"
     # Your code here...
     
     return 0  # Return success
   }
   ```

2. **Add to command dispatch in `main()`**:
   ```bash
   case "$cmd" in
     # ...existing commands...
     newcommand)    handle_cmd_newcommand "$args" || true ;;
     # ...other commands...
   esac
   ```

3. **Add documentation in `/help` output**:
   ```bash
   # In handle_cmd_help function:
   info "  /newcommand      Description of your new command"
   ```

4. **Update user documentation** in README.md and/or USAGE.md

5. **Add tests** for the new command in the appropriate test file

### State Management

The dbh script maintains state using global variables:

- **Database Context**:
  - `Database` - Current selected database name
  - `DataTable` - Current selected table name
  - `PromptPrefix` - Current prompt showing context

- **Query State**:
  - `SelectedColumns` - Array of column names for SELECT
  - `WhereClause` - WHERE clause for the query
  - `OrderClause` - ORDER BY clause
  - `OrderDirection` - Sort direction (ASC/DESC)
  - `LimitClause` - LIMIT value

- **Configuration**:
  - `PROFILE` - Path to MySQL config file
  - `VERBOSE` - Verbosity level
  - Various configuration options loaded from config file

### Error Handling

The script uses several mechanisms for robust error handling:

1. **Shell Options**:
   - `set -e` - Exit on error
   - `set -u` - Error on undefined variables
   - `set -o pipefail` - Pipeline fails if any command fails

2. **Error Reporting Functions**:
   - `error()` - Display error message
   - `warn()` - Display warning
   - `die()` - Display fatal error and exit

3. **Command Error Handling**:
   - Command handlers return non-zero on error
   - Main dispatch uses `|| true` to prevent script termination
   - Error messages provide clear feedback

4. **MySQL Error Handling**:
   - `mysql_exec()` captures and formats MySQL errors
   - Properly handles exit codes from MySQL
   - Formats error messages for readability

### Security Implementation

Security is implemented through several key mechanisms:

1. **SQL Injection Prevention**:
   - `quote_ident()` function:
     ```bash
     # Double backticks within identifiers (MySQL's escaping rule for identifiers)
     ident="${ident//\`/\`\`}"
     echo "\`$ident\`"
     ```
   - `escape_sql_value()` function:
     ```bash
     # Replace single quotes with two single quotes (SQL standard escaping)
     value="${value//\'/\'\'}"
     echo "'$value'"
     ```

2. **Temporary File Security**:
   - `create_secure_tempfile()` function creates files with 0600 permissions
   - Files are created in user-writable temporary directories
   - Files are properly cleaned up via trap commands

3. **Credential Management**:
   - MySQL credentials kept in configuration files
   - No command-line password usage
   - Configuration files recommended to have restricted permissions

4. **Input Validation**:
   - User inputs are validated before use
   - Context requirements are enforced
   - Error messages avoid exposing sensitive details

## Feature Roadmap

Future development might include:

- **Enhanced Output Formats**:
  - JSON output format option
  - CSV export enhancements
  - Custom formatting templates

- **Improved Visualization**:
  - Better visualization for table relationships
  - Schema diagrams
  - Color-coded data view options

- **Connection Management**:
  - Multiple simultaneous database connections
  - Connection profiles
  - Connection pooling

- **Session Management**:
  - Session saving and resuming
  - Named sessions
  - Session variables

- **Automation Features**:
  - Scripting capability
  - Macro recording
  - Scheduled operations

- **Data Modification**:
  - Table data editing capabilities
  - Bulk import/export improvements
  - Data generation utilities

- **Advanced Features**:
  - Transaction support
  - Enhanced search capabilities
  - Explain plan visualization

## Contributing

Contributions to dbh are welcome! Here's how to contribute:

### Contribution Workflow

1. **Find or create an issue** to discuss the change you want to make
2. **Fork the repository** and create a feature branch
3. **Make your changes** following the coding principles
4. **Run shellcheck** to ensure code quality
5. **Add/update tests** to verify your changes
6. **Run tests** to ensure all tests pass
7. **Update documentation** as needed
8. **Submit a pull request** with a clear description of changes

### Commit Guidelines

- Use clear, descriptive commit messages
- Reference issues when applicable
- Use the format: `[type]: Brief description of change`
  - Types: `fix`, `feat`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep changes focused on a single feature or fix
- Keep commits small and atomic
- Example: `feat: Add table export to JSON format (#42)`

### Pull Request Process

1. Create a pull request from your feature branch to the main branch
2. Fill in the pull request template with:
   - Description of changes
   - Issue references
   - Testing performed
   - Documentation updates
3. Respond to review comments and make requested changes
4. Once approved, maintainers will merge your pull request

## License

dbh is licensed under GNU General Public License v3.0 (GPL-3.0). Any contributions must be compatible with this license.

The full text of the license can be found in the [LICENSE](LICENSE) file. In summary, GPL-3.0 grants the following permissions:

1. The freedom to use the software for any purpose
2. The freedom to change the software to suit your needs
3. The freedom to share the software with friends and neighbors
4. The freedom to share the changes you make

When you contribute to the project, you agree to license your code under the same GPL-3.0 license.