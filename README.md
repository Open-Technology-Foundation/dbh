# dbh - MySQL Interactive Client

A fast, intuitive MySQL database explorer with color-coded interface, configuration system, and persistent command history.

## Description

`dbh` (version 3.7.1) is a MySQL database helper utility designed to streamline database interaction through a hierarchical command interface. The tool provides quick navigation of databases and tables, simplifies query construction, offers direct SQL execution, and maintains shell access—all while preserving context.

Key aspects:
- **Color-Coded Interface**: User-friendly prompts and messages with color differentiation
- **Context-Aware**: Maintains awareness of current database and table selections
- **Configuration System**: Customize behavior through `~/.config/dbh/config`
- **Command History**: Persistent across sessions with arrow key navigation
- **Command Types**: Slash commands (`/databases`), shell commands (`!ls`), and direct SQL
- **Security-Focused**: Prevents SQL injection and handles credentials securely
- **Query Builder**: Interactively construct SQL queries with intuitive commands
- **Shell Integration**: Run system commands while maintaining database context

The tool serves as a productivity enhancer for database administrators and developers who need to quickly explore, query, and manage MySQL databases without the overhead of remembering complex SQL syntax.

## Features

- **Interactive Navigation** - Browse databases and tables with menu-driven selection
- **Color-Coded Interface** - Differentiated colors for prompts, messages, and errors
- **Configuration System** - Customize settings via ~/.config/dbh/config
- **Command History** - Persistent across sessions with arrow key navigation
- **Direct SQL** - Run queries without prefixes when a database is selected
- **Shell Access** - Execute shell commands with `!` prefix or enter interactive shell
- **Query Building** - Construct SELECT queries interactively with intuitive commands
- **Rich Output** - Tabular display with horizontal scrolling for wide tables
- **Detailed Structure** - View table structures, columns, indexes, and status

## Installation

1. Download the script:
   ```bash
   curl -o dbh https://raw.githubusercontent.com/yourusername/dbh/main/dbh
   chmod +x dbh
   ```

2. Create a MySQL config file (Default: `~/.mylocalhost.cnf`):
   ```ini
   [client]
   host=localhost
   user=your_username
   password=your_password
   ```

3. Run the script:
   ```bash
   ./dbh [options] [database [table]]
   ```

4. Optionally create a configuration file:
   ```bash
   ./dbh
   # From within dbh:
   [dbh]> /config create
   ```

## Usage

```
dbh v3.7.1 - Interactive MySQL client with slash commands, shell access, and direct SQL

Usage:
  dbh [Options] [database [table]]

  database  Optional: Initial database to connect to
  table     Optional: Initial table to select
```

### Command Types

- `/command` - Database operations (prefixed with /)
- `!command` - Shell commands (prefixed with !)
- `SQL query` - Direct SQL (no prefix needed)

### Key Commands

**Navigation:**
- `/databases` - List and select a database
- `/tables` - List and select a table
- `/..` or `/back` - Go back one level

**Query Building:**
- `/columns` - Select columns (shows multi-select menu)
- `/where` - Set WHERE clause
- `/order` - Set ORDER BY columns
- `/limit` - Set LIMIT
- `/select` - Execute the query

**Table Information:**
- `/describe` - Basic table structure
- `/structure` - Detailed column information
- `/status` - Table status information

**Configuration and Utilities:**
- `/config show` - Display current configuration
- `/config create` - Create default config file
- `/config edit` - Open config file in editor
- `/config reload` - Reload configuration

**History and Shell:**
- `/history` - Show command history
- `↑/↓` - Navigate history with arrow keys
- `!number` - Recall command by number
- `!` - Launch interactive shell
- `!command` - Execute shell command
- `/help` - Show help

## Examples

```bash
# Start with a specific database and table
dbh mydb users

# Interactive navigation with color-coded prompts
[dbh]> /databases
[dbh:mydb]> /tables
[dbh:mydb:users]> /describe

# Building queries with interactive prompts
[dbh:mydb:users]> /columns id,name,email
[dbh:mydb:users]> /where active=1
[dbh:mydb:users]> /select

# Direct SQL (no prefix needed)
[dbh:mydb:users]> SELECT COUNT(*) FROM users WHERE status='active'
[dbh:mydb:users]> UPDATE users SET last_login=NOW() WHERE id=123

# Configuration management
[dbh]> /config create     # Create default configuration file
[dbh]> /config edit       # Edit settings in your text editor
[dbh]> /config reload     # Apply configuration changes

# History and shell access
[dbh]> /history           # View command history
[dbh]> !ls -la            # Run shell command
[dbh]> !                  # Launch interactive shell
# Use arrow keys ↑/↓ to navigate through previous commands
```

## Options

- `-p, --profile PROFILE` - MySQL config file (Default: ~/.mylocalhost.cnf)
- `-v, --verbose` - Increase verbosity
- `-q, --quiet` - Suppress non-error messages
- `-h, --help` - Display help

## Requirements

- Bash 4.0 or higher
- MySQL client (`mysql` command in PATH)
- `less` pager (optional, for better viewing of wide results)

## Configuration

The configuration file is stored at `~/.config/dbh/config` and supports these options:

```
# MySQL configuration file
DEFAULT_PROFILE=~/.mylocalhost.cnf

# Default database on startup
# DEFAULT_DATABASE=mysql

# Default limit for SELECT queries
DEFAULT_LIMIT=100

# Maximum history entries
MAX_HISTORY=1000

# Pager program
# PAGER=less -S
```

You can create and manage this file using the `/config` commands.

## License

MIT

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.