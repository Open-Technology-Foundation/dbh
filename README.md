# dbh - MySQL Interactive Client

A fast and intuitive MySQL database explorer with command-line navigation, direct SQL, and shell access.

## Features

- **Interactive Navigation** - Browse databases and tables with menu-driven selection
- **Direct SQL** - Run SQL queries without prefixes when a database is selected
- **Shell Access** - Execute shell commands with `!` prefix or enter interactive shell
- **Query Building** - Construct SELECT queries interactively with intuitive commands
- **Rich Output** - Boxed tabular display with horizontal scrolling for wide tables
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

## Usage

```
dbh v3.0.7 - Interactive MySQL client with slash commands, shell access, and direct SQL

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

**Other:**
- `/sql <query>` - Execute arbitrary SQL
- `!` - Launch interactive shell
- `!command` - Execute shell command
- `/help` - Show help

## Examples

```bash
# Start with a specific database and table
dbh mydb users

# Interactive navigation
[dbh]> /databases
[dbh:mydb]> /tables
[dbh:mydb:users]> /describe

# Building queries
[dbh:mydb:users]> /columns id,name,email
[dbh:mydb:users]> /where active=1
[dbh:mydb:users]> /select

# Direct SQL (no prefix needed)
[dbh:mydb:users]> SELECT COUNT(*) FROM users WHERE status='active'
[dbh:mydb:users]> UPDATE users SET last_login=NOW() WHERE id=123

# Using shell commands
[dbh:mydb:users]> ! ls -la
[dbh:mydb:users]> ! grep -r "password" /etc/mysql/
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

## License

MIT

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.