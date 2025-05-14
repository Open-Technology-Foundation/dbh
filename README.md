# dbh - Interactive MySQL Database Helper

A powerful, intuitive MySQL database explorer with an interactive command interface, colorized output, and comprehensive database management capabilities.

![Version](https://img.shields.io/badge/Version-3.7.1-blue)
![License](https://img.shields.io/badge/License-GPL--3.0-green)
![Bash](https://img.shields.io/badge/Language-Bash-yellow)

## Overview

`dbh` (version 3.7.1) is a MySQL database helper utility designed to streamline database interaction through a hierarchical command interface. It combines the power of the MySQL command-line client with an intuitive, context-aware interface that maintains your working environment as you navigate between databases and tables.

### Why Use dbh?

- **Reduce Repetitive Typing** - No need to retype database and table names
- **Faster Exploration** - Navigate databases and tables with intuitive slash commands
- **Interactive Query Building** - Build complex queries step-by-step without typing full SQL
- **Avoid SQL Syntax Errors** - Commands help construct properly formatted queries
- **Maintain Context** - Keep your database and table selection across operations
- **Enhanced Security** - Built-in protections against SQL injection
- **Seamless Shell Integration** - Run system commands without losing database context

### Key Features

- **Interactive Navigation** - Navigate databases and tables through menu-driven interfaces
- **Context Awareness** - Maintains your selection context as you move between operations
- **Color-Coded Interface** - Differentiated colors for prompts, messages, and errors
- **Query Building** - Construct SELECT queries interactively with intuitive commands
- **Direct SQL** - Execute SQL statements directly without prefixes
- **Shell Integration** - Execute shell commands while maintaining database context
- **Command History** - Persistent history across sessions with arrow key navigation
- **Security-Focused** - Prevents SQL injection with proper parameter escaping
- **Export Capabilities** - Export query results in CSV, JSON, or SQL formats
- **Table Analysis** - Examine schema, indexes, foreign keys and relationships

## Installation

### Prerequisites

- Bash 5.0+ (4.0+ will work with reduced functionality)
- MySQL client (`mysql` command in PATH)
- MySQL server (local or remote)
- `less` pager (optional, for improved viewing of wide results)

### Setup

1. **Download the script:**
   ```bash
   curl -o dbh https://raw.githubusercontent.com/Open-Technology-Foundation/dbh/main/dbh
   chmod +x dbh
   ```

2. **Create a MySQL config file** (default: `~/.mylocalhost.cnf`):
   ```ini
   [client]
   host=localhost
   user=your_username
   password=your_password
   ```

   This approach keeps your credentials secure and avoids exposing them on the command line.

3. **Create a configuration file** (optional):
   ```bash
   mkdir -p ~/.config/dbh
   cp config.example ~/.config/dbh/config
   ```

4. **Add to your PATH** (optional):
   ```bash
   echo 'export PATH="$PATH:/path/to/dbh/directory"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Quick Start

```bash
# Start with a specific database and table
dbh mydb users

# Interactive navigation
[dbh]> /databases             # List and select database
[dbh:mydb]> /tables           # List and select table
[dbh:mydb:users]> /describe   # Show table structure

# Building queries
[dbh:mydb:users]> /columns id,name,email
[dbh:mydb:users]> /where active=1
[dbh:mydb:users]> /limit 10
[dbh:mydb:users]> /select

# Direct SQL (no prefix needed)
[dbh:mydb:users]> SELECT COUNT(*) FROM users WHERE status='active'

# Shell access
[dbh:mydb:users]> !ls -la     # Run shell command
[dbh:mydb:users]> !           # Launch interactive shell
```

## Usage

```
dbh v3.7.1 - Interactive MySQL client with slash commands, shell access, and direct SQL

Usage:
  dbh [Options] [database [table [command]]]

  database  Optional: Initial database to connect to
  table     Optional: Initial table to select
  command   Optional: Initial command to execute

Options:
  -p, --profile PROFILE  MySQL config file (Default: ~/.mylocalhost.cnf)
  -v, --verbose   Increase verbosity
  -q, --quiet     Suppress non-error messages
  -V, --version   Print version and exit
  -h, --help      Display this help
```

### Command Types

- `/command` - Database operations (prefixed with `/`)
- `!command` - Shell commands (prefixed with `!`)
- `SQL query` - Direct SQL execution (no prefix needed)
- `!number` - Repeat command from history by number

### Prompt Format

The prompt always shows your current context:

- `[dbh]` - No database selected
- `[dbh:mysql]` - Database "mysql" selected
- `[dbh:sakila:film]` - Database "sakila" and table "film" selected

### Key Commands

#### Navigation

| Command | Description |
|---------|-------------|
| `/databases` | List and select a database |
| `/database <db>` | Directly select database |
| `/tables` | List and select a table |
| `/table <n>` | Directly select table |
| `/..` or `/back` or `/0` | Go back one level |
| `/q` or `/quit` or `/exit` | Exit the program |

#### Query Building

| Command | Description |
|---------|-------------|
| `/columns [cols]` | Set columns (shows interactive menu if no arguments) |
| `/where [clause]` | Set WHERE clause |
| `/order [cols]` | Set ORDER BY columns |
| `/asc` or `/desc` | Set sort order direction |
| `/limit [num]` | Set LIMIT |
| `/select` | Execute query with current state |
| `/state` | Show current query state |

#### Table Operations

| Command | Description |
|---------|-------------|
| `/describe` | Show table structure |
| `/structure [v]` | Detailed column info (v=vertical format) |
| `/status` | Show table status |
| `/create` | Show CREATE TABLE statement |
| `/count` | Show row count |
| `/sample [n]` | Show n sample rows (default: 10) |
| `/primary-key` | Show primary key columns |
| `/indexes` | Show all indexes |
| `/foreign-keys` | Show foreign key relationships |
| `/find <text>` | Search for text in all columns |
| `/backup [file]` | Backup table to SQL file |

#### Database Operations

| Command | Description |
|---------|-------------|
| `/schema [v]` | Show database schema with relationships |
| `/charset` | Show character set information |
| `/engines` | List available storage engines |
| `/backup [file]` | Backup current database to SQL file |

#### Administration

| Command | Description |
|---------|-------------|
| `/whoami` | Show current MySQL user and privileges |
| `/whois [user]` | Show information about a specific MySQL user |
| `/users` | Show MySQL users and privileges |
| `/processes` | Show active MySQL processes |
| `/variables [filter]` | Display MySQL system variables |
| `/stats` | Show database/table statistics |
| `/export [file]` | Export query results to file (CSV/SQL/JSON) |
| `/sql <SQL>` | Execute arbitrary SQL |
| `/prompt` | Open MySQL prompt |

#### Configuration and History

| Command | Description |
|---------|-------------|
| `/config show` | Display current configuration |
| `/config create` | Create default config file |
| `/config edit` | Open config file in editor |
| `/config reload` | Reload configuration |
| `/history [n]` | Show command history (last n entries) |
| `↑/↓` | Navigate history with arrow keys |

See the [COMMANDS.md](COMMANDS.md) file for a complete command reference and [USAGE.md](USAGE.md) for more detailed examples and advanced usage scenarios.

## Configuration

The configuration file is stored at `~/.config/dbh/config` and supports these options:

```ini
# Default MySQL configuration file
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

You can create and manage this file using the `/config` commands within dbh.

## Advanced Usage Examples

### Interactive Query Building

```bash
# Start building a query
[dbh:mydb:users]> /columns    # Opens multi-select menu for columns
[dbh:mydb:users]> /where created_at > '2023-01-01'
[dbh:mydb:users]> /order last_login
[dbh:mydb:users]> /desc       # Sort descending
[dbh:mydb:users]> /limit 50
[dbh:mydb:users]> /select     # Execute the query
```

### Export and Backup

```bash
# Export query results
[dbh:mydb:users]> /export users_export.csv
[dbh:mydb:users]> /export --format json users.json

# Backup table or database
[dbh:mydb:users]> /backup users_backup.sql
[dbh:mydb]> /backup mydb_full.sql
```

### Shell Integration

```bash
# Run single shell command
[dbh:mydb]> !ls -la

# Launch interactive shell
[dbh:mydb]> !
$ echo "Do something in shell"
$ exit
[dbh:mydb]> # Back to dbh
```

### Command History

```bash
# Show history
[dbh]> /history 20    # Show last 20 commands

# Recall command by number
[dbh]> !5             # Execute history command #5

# Use arrow keys to navigate previous commands
# Press Up/Down arrows to cycle through history
```

## Security Features

- **SQL Injection Prevention** - All user inputs are properly escaped using proven techniques
- **Secure Credential Handling** - Uses MySQL configuration files instead of command-line passwords
- **Temporary File Security** - Creates temp files with secure permissions (0600)
- **Proper Cleanup** - Removes temporary files on exit
- **Error Handling** - Properly catches and reports errors without exposing sensitive information
- **Safe Defaults** - Conservative default settings to prevent accidental data exposure

## Documentation

- **[USAGE.md](USAGE.md)** - Comprehensive usage examples and advanced techniques
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Information for developers interested in contributing
- **[PURPOSE-FUNCTIONALITY-USAGE.md](PURPOSE-FUNCTIONALITY-USAGE.md)** - Detailed explanation of the tool's purpose and design principles

## License

GNU General Public License v3.0 (GPL-3.0)

dbh is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The full text of the license can be found in the [LICENSE](LICENSE) file.

## Contributing

Contributions are welcome! Please submit pull requests to the [official repository](https://github.com/Open-Technology-Foundation/dbh). See [DEVELOPMENT.md](DEVELOPMENT.md) for guidelines on development and contribution.

## Support

If you encounter issues or have questions, please open an issue on the [GitHub repository](https://github.com/Open-Technology-Foundation/dbh/issues).