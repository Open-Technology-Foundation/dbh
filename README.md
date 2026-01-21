# dbh - Interactive MySQL Database Helper

Navigate databases like a filesystem. Build queries interactively. Keep your context.

![Version](https://img.shields.io/badge/Version-3.7.1-blue)
![License](https://img.shields.io/badge/License-GPL--3.0-green)
![Bash](https://img.shields.io/badge/Language-Bash-yellow)

## What You Can Do

### Database Exploration

Browse databases and tables without typing repetitive SQL:

```bash
[dbh]> /databases           # List and select database
[dbh:sakila]> /tables       # List and select table
[dbh:sakila:film]> /sample  # See sample data immediately
```

### Interactive Query Building

Construct SELECT queries step-by-step:

```bash
[dbh:sakila:film]> /columns title,release_year,rating
[dbh:sakila:film]> /where rating='PG'
[dbh:sakila:film]> /order release_year
[dbh:sakila:film]> /desc
[dbh:sakila:film]> /limit 20
[dbh:sakila:film]> /select
```

### Schema Analysis

Examine table structures, indexes, and relationships:

```bash
[dbh:sakila:film]> /describe      # Column types and constraints
[dbh:sakila:film]> /indexes       # All indexes on table
[dbh:sakila:film]> /foreign-keys  # FK relationships
[dbh:sakila]> /schema             # Full database schema with relationships
```

### Data Export

Export query results to CSV, JSON, or SQL:

```bash
[dbh:sakila:film]> /export films.csv
[dbh:sakila:film]> /export --format json films.json
[dbh:sakila:film]> /backup film_backup.sql
```

### Administration

Monitor processes and check privileges:

```bash
[dbh]> /whoami       # Current user and privileges
[dbh]> /processes    # Active MySQL processes
[dbh]> /users        # All MySQL users
[dbh]> /variables    # System variables
```

### Shell Integration

Run shell commands without losing your database context:

```bash
[dbh:sakila:film]> !ls -la       # Single command
[dbh:sakila:film]> !             # Interactive shell, exit returns to dbh
[dbh:sakila:film]> !5            # Recall history command #5
```

## Quick Start

```bash
# Install
curl -o dbh https://raw.githubusercontent.com/Open-Technology-Foundation/dbh/main/dbh
chmod +x dbh

# Create MySQL credentials file
cat > ~/.mylocalhost.cnf << 'EOF'
[client]
host=localhost
user=your_username
password=your_password
EOF
chmod 600 ~/.mylocalhost.cnf

# Connect and explore
./dbh sakila
/tables
/table film
/sample 5
```

## Installation

### Prerequisites

- Bash 5.0+ (4.0+ with reduced functionality)
- MySQL client (`mysql` command in PATH)
- MySQL server (local or remote)
- `less` pager (optional, for wide results)

### Setup Options

**Option A: Direct download**
```bash
curl -o dbh https://raw.githubusercontent.com/Open-Technology-Foundation/dbh/main/dbh
chmod +x dbh
sudo mv dbh /usr/local/bin/  # Optional: make available system-wide
```

**Option B: Clone repository**
```bash
git clone https://github.com/Open-Technology-Foundation/dbh.git
cd dbh
chmod +x dbh
```

### MySQL Credentials

Create a MySQL config file (keeps credentials out of command line):

```ini
# ~/.mylocalhost.cnf
[client]
host=localhost
user=your_username
password=your_password
```

Set permissions: `chmod 600 ~/.mylocalhost.cnf`

Use different profiles for different servers:
```bash
dbh -p ~/.myremoteserver.cnf production_db
```

## Command Types

| Prefix | Type | Example | Description |
|--------|------|---------|-------------|
| `/` | Slash command | `/tables` | Database operations |
| `!` | Bang command | `!ls -la` | Shell commands |
| (none) | Direct SQL | `SELECT * FROM users` | Execute SQL directly |
| `!N` | History recall | `!5` | Re-run command #5 |

### Prompt Context

The prompt shows your current selection:

- `[dbh]` - No database selected
- `[dbh:mysql]` - Database "mysql" selected
- `[dbh:sakila:film]` - Database and table selected

## Command Overview

| Category | Key Commands | Description |
|----------|--------------|-------------|
| **Navigation** | `/databases`, `/tables`, `/..` | Browse and select databases/tables |
| **Query Building** | `/columns`, `/where`, `/order`, `/select` | Build SELECT queries interactively |
| **Table Info** | `/describe`, `/indexes`, `/foreign-keys`, `/find` | Examine table structure |
| **Database Info** | `/schema`, `/charset`, `/engines` | Database-level information |
| **Export** | `/export`, `/backup` | Export data to CSV/JSON/SQL |
| **Admin** | `/whoami`, `/users`, `/processes`, `/variables` | Server administration |
| **History** | `/history`, `!N`, arrow keys | Command history access |
| **Config** | `/config show`, `/config edit` | Configuration management |
| **Utility** | `/help`, `/state`, `/count`, `/sample` | General utilities |

For the complete command reference with examples, see [USAGE.md](USAGE.md).

## Configuration

Configuration file: `~/.config/dbh/config`

```ini
# Default MySQL configuration file
DEFAULT_PROFILE=~/.mylocalhost.cnf

# Default database on startup (optional)
# DEFAULT_DATABASE=mysql

# Default LIMIT for SELECT queries
DEFAULT_LIMIT=100

# Maximum history entries
MAX_HISTORY=1000

# Pager program (optional)
# PAGER=less -S
```

Manage configuration within dbh:
```bash
/config show     # Display current settings
/config create   # Create default config file
/config edit     # Open in editor
/config reload   # Reload after manual changes
```

## Security

- **SQL Injection Prevention** - User inputs are escaped using `quote_ident()` and `escape_sql_value()`
- **Credential Security** - Uses MySQL config files, never command-line passwords
- **Secure Temp Files** - Created with 0600 permissions, cleaned up on exit
- **Error Handling** - Errors reported without exposing sensitive information

## Usage

```
dbh v3.7.1 - Interactive MySQL client with slash commands, shell access, and direct SQL

Usage:
  dbh [Options] [database [table [command]]]

Options:
  -p, --profile PROFILE  MySQL config file (Default: ~/.mylocalhost.cnf)
  -v, --verbose          Increase verbosity
  -q, --quiet            Suppress non-error messages
  -V, --version          Print version and exit
  -h, --help             Display this help
```

## Documentation

| Document | Description |
|----------|-------------|
| [USAGE.md](USAGE.md) | Complete command reference with detailed examples |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Contributing guidelines and architecture |

## License

GNU General Public License v3.0 (GPL-3.0)

See [LICENSE](LICENSE) for the full text.

## Support

- **Issues**: [GitHub Issues](https://github.com/Open-Technology-Foundation/dbh/issues)
- **Repository**: [github.com/Open-Technology-Foundation/dbh](https://github.com/Open-Technology-Foundation/dbh)
- **Contributions**: See [DEVELOPMENT.md](DEVELOPMENT.md) for guidelines
