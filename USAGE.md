# dbh Usage Guide and Command Reference

This document provides comprehensive usage examples and a complete command reference for the dbh MySQL database helper utility, showcasing its capabilities and helping users make the most of its features.

## Table of Contents

- [Command Types](#command-types)
- [Basic Navigation](#basic-navigation)
- [Navigation Commands](#navigation-commands)
- [Query Building](#query-building)
- [Query Building Commands](#query-building-commands)
- [Table Exploration](#table-exploration)
- [Table Operations](#table-operations)
- [Database Management](#database-management)
- [Database Operations](#database-operations)
- [Data Export and Backup](#data-export-and-backup)
- [Export and Backup Commands](#export-and-backup-commands)
- [Administration](#administration)
- [Administration Commands](#administration-commands)
- [Shell Integration](#shell-integration)
- [Shell Commands](#shell-commands)
- [Command History](#command-history)
- [History and Help Commands](#history-and-help-commands)
- [Configuration](#configuration)
- [Configuration Commands](#configuration-commands)
- [Advanced Techniques](#advanced-techniques)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Command Types

dbh supports four distinct command types:

1. **Slash Commands** - Database operations prefixed with `/` (e.g., `/database`, `/tables`)
2. **Bang Commands** - Shell operations prefixed with `!` (e.g., `!ls`, `!grep`)
3. **SQL Queries** - Direct SQL execution without a prefix
4. **History Recall** - Commands recalled from history with `!number`

## Basic Navigation

### Starting dbh

```bash
# Start with no specific database
dbh

# Start with a specific database
dbh mysql

# Start with a specific database and table
dbh sakila film

# Start with a specific profile
dbh -p ~/.myremoteserver.cnf

# Quiet mode (suppress informational messages)
dbh -q
```

### Database Navigation

```bash
# List and select database interactively
[dbh]> /databases

# Directly select a database
[dbh]> /database sakila

# List and select table interactively
[dbh:sakila]> /tables

# Directly select a table
[dbh:sakila]> /table film

# Go back one level (table → database → exit)
[dbh:sakila:film]> /..   # or /back or /0
[dbh:sakila]> /..        # Now back at database level

# Exit dbh
[dbh]> /q    # or /quit or /exit
```

### Context-Aware Interface

The prompt always shows your current context:

- `[dbh]` - No database selected
- `[dbh:mysql]` - Database "mysql" selected
- `[dbh:sakila:film]` - Database "sakila" and table "film" selected

## Navigation Commands

### /databases

Lists all available databases and allows interactive selection.

**Synopsis:**
```
/databases
```

**Context Required:** None

**Description:**  
Displays a numbered list of all databases that the current MySQL user has access to. You can select a database by entering its number from the list.

**Examples:**
```
[dbh]> /databases
1) information_schema
2) mysql
3) performance_schema
4) sakila
5) sys
Enter database number (or 0 to cancel): 4
Using database 'sakila'.
```

### /database

Directly selects a specific database by name.

**Synopsis:**
```
/database <database_name>
```

**Context Required:** None

**Arguments:**
- `database_name` - Name of the database to select

**Description:**  
Directly selects the specified database without showing a list. If the database exists and the user has access to it, it becomes the current working database.

**Examples:**
```
[dbh]> /database sakila
Using database 'sakila'.
```

### /tables

Lists all tables in the current database and allows interactive selection.

**Synopsis:**
```
/tables
```

**Context Required:** Database

**Description:**  
Displays a numbered list of all tables in the currently selected database. You can select a table by entering its number from the list.

**Examples:**
```
[dbh:sakila]> /tables
1) actor
2) address
3) category
4) city
5) country
...
Enter table number (or 0 to cancel): 1
Using table 'actor'.
```

### /table

Directly selects a specific table by name.

**Synopsis:**
```
/table <table_name>
```

**Context Required:** Database

**Arguments:**
- `table_name` - Name of the table to select

**Description:**  
Directly selects the specified table in the current database without showing a list.

**Examples:**
```
[dbh:sakila]> /table actor
Using table 'actor'.
```

### /..

Navigates up one level in the context hierarchy.

**Synopsis:**
```
/..
```
or
```
/back
```
or
```
/0
```

**Context Required:** Any

**Description:**  
Moves up one level in the context hierarchy. If a table is selected, it deselects the table but keeps the database selected. If a database is selected with no table, it deselects the database.

**Examples:**
```
[dbh:sakila:actor]> /..
[dbh:sakila]> /..
[dbh]>
```

### /quit

Exits the dbh utility.

**Synopsis:**
```
/quit
```
or
```
/q
```
or
```
/exit
```

**Context Required:** None

**Description:**  
Terminates the dbh session, saving history before exiting.

**Examples:**
```
[dbh]> /quit
Goodbye!
```

## Query Building

### Interactive SELECT Query Construction

```bash
# Select a table first
[dbh:sakila]> /table film

# Set specific columns (with interactive menu)
[dbh:sakila:film]> /columns
# Multi-select menu appears for column selection

# Or specify columns directly
[dbh:sakila:film]> /columns film_id,title,release_year

# Add WHERE clause
[dbh:sakila:film]> /where release_year > 2000

# Add ORDER BY
[dbh:sakila:film]> /order title

# Specify sort direction
[dbh:sakila:film]> /desc  # descending order
# or
[dbh:sakila:film]> /asc   # ascending order

# Set a row limit
[dbh:sakila:film]> /limit 20

# View the current query state
[dbh:sakila:film]> /state

# Execute the built query
[dbh:sakila:film]> /select
```

### Direct SQL Execution

```bash
# Execute any SQL query directly
[dbh:sakila]> SELECT film_id, title FROM film WHERE length > 120 ORDER BY title LIMIT 10

# Execute potentially destructive operations (with confirmation)
[dbh:sakila]> UPDATE film SET rental_rate = 4.99 WHERE film_id = 1

# Execute complex queries
[dbh:sakila]> SELECT f.title, c.name 
              FROM film f 
              JOIN film_category fc ON f.film_id = fc.film_id 
              JOIN category c ON fc.category_id = c.category_id 
              WHERE c.name = 'Horror' 
              ORDER BY f.title
```

## Query Building Commands

### /columns

Sets the columns to include in a SELECT query.

**Synopsis:**
```
/columns [column1,column2,...]
```

**Context Required:** Table

**Arguments:**
- `column1,column2,...` - Optional comma-separated list of column names

**Description:**  
If called without arguments, displays an interactive menu for selecting columns. If called with a comma-separated list, sets those columns for the query.

**Examples:**
```
[dbh:sakila:actor]> /columns first_name,last_name
Columns set to: first_name,last_name
```

### /where

Sets the WHERE clause for a SELECT query.

**Synopsis:**
```
/where [condition]
```

**Context Required:** Table

**Arguments:**
- `condition` - Optional WHERE condition

**Description:**  
Sets the WHERE clause for the query. If called without arguments, clears any existing WHERE clause.

**Examples:**
```
[dbh:sakila:actor]> /where last_name LIKE 'A%'
WHERE clause set to: last_name LIKE 'A%'
```

### /order

Sets the ORDER BY clause for a SELECT query.

**Synopsis:**
```
/order [columns]
```

**Context Required:** Table

**Arguments:**
- `columns` - Optional comma-separated list of columns to order by

**Description:**  
Sets the ORDER BY clause for the query. If called without arguments, clears any existing ORDER BY clause.

**Examples:**
```
[dbh:sakila:actor]> /order last_name
ORDER BY set to: last_name
```

### /asc

Sets the sort order to ascending.

**Synopsis:**
```
/asc
```

**Context Required:** Table

**Description:**  
Sets the sort direction to ASC (ascending) for the ORDER BY clause.

**Examples:**
```
[dbh:sakila:actor]> /asc
Sort order set to: ASC
```

### /desc

Sets the sort order to descending.

**Synopsis:**
```
/desc
```

**Context Required:** Table

**Description:**  
Sets the sort direction to DESC (descending) for the ORDER BY clause.

**Examples:**
```
[dbh:sakila:actor]> /desc
Sort order set to: DESC
```

### /limit

Sets the LIMIT clause for a SELECT query.

**Synopsis:**
```
/limit [count]
```

**Context Required:** Table

**Arguments:**
- `count` - Optional row count limit

**Description:**  
Sets the maximum number of rows to return in the query. If called without arguments, uses the default limit from configuration.

**Examples:**
```
[dbh:sakila:actor]> /limit 10
LIMIT set to: 10
```

### /select

Executes the SELECT query with the current state.

**Synopsis:**
```
/select
```

**Context Required:** Table

**Description:**  
Combines all query components (columns, WHERE, ORDER BY, LIMIT) and executes the SELECT query.

**Examples:**
```
[dbh:sakila:actor]> /columns first_name,last_name
[dbh:sakila:actor]> /where last_name LIKE 'A%'
[dbh:sakila:actor]> /order last_name
[dbh:sakila:actor]> /limit 5
[dbh:sakila:actor]> /select
+------------+-----------+
| first_name | last_name |
+------------+-----------+
| CHRISTIAN  | AKROYD    |
| DEBBIE     | AKROYD    |
| KIRSTEN    | AKROYD    |
| CUBA       | ALLEN     |
| KIM        | ALLEN     |
+------------+-----------+
5 rows in set
```

### /state

Shows the current query state.

**Synopsis:**
```
/state
```

**Context Required:** Table

**Description:**  
Displays the current state of all query components (columns, WHERE, ORDER BY, LIMIT).

**Examples:**
```
[dbh:sakila:actor]> /state
Current query state:
  Database:    sakila
  Table:       actor
  Columns:     first_name,last_name
  WHERE:       last_name LIKE 'A%'
  ORDER BY:    last_name ASC
  LIMIT:       5
```

## Table Exploration

### Table Structure

```bash
# View basic table structure
[dbh:sakila:film]> /describe

# View detailed column information
[dbh:sakila:film]> /structure

# View in vertical format
[dbh:sakila:film]> /structure v

# Show table status information
[dbh:sakila:film]> /status

# Show CREATE TABLE statement
[dbh:sakila:film]> /create

# Get row count
[dbh:sakila:film]> /count
```

### Key and Index Information

```bash
# Show primary key columns
[dbh:sakila:film]> /primary-key

# Show all indexes
[dbh:sakila:film]> /indexes

# Show foreign key relationships
[dbh:sakila:film]> /foreign-keys
```

### Data Sampling and Searching

```bash
# Sample 10 rows (default)
[dbh:sakila:film]> /sample

# Sample specific number of rows
[dbh:sakila:film]> /sample 5

# Search for text in all columns
[dbh:sakila:film]> /find DINOSAUR
```

## Table Operations

### /describe

Shows the basic structure of the selected table.

**Synopsis:**
```
/describe
```

**Context Required:** Table

**Description:**  
Displays the basic structure of the table, including column names, types, and key information.

**Examples:**
```
[dbh:sakila:actor]> /describe
+-------------+----------------------------+------+-----+-------------------+-------------------+
| Field       | Type                       | Null | Key | Default           | Extra             |
+-------------+----------------------------+------+-----+-------------------+-------------------+
| actor_id    | smallint unsigned          | NO   | PRI | NULL              | auto_increment    |
| first_name  | varchar(45)                | NO   |     | NULL              |                   |
| last_name   | varchar(45)                | NO   | MUL | NULL              |                   |
| last_update | timestamp                  | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+-------------+----------------------------+------+-----+-------------------+-------------------+
```

### /structure

Shows detailed column information for the selected table.

**Synopsis:**
```
/structure [v]
```

**Context Required:** Table

**Arguments:**
- `v` - Optional flag for vertical format

**Description:**  
Displays detailed information about the table structure, including column properties, constraints, and indexes. The optional 'v' flag displays the information in vertical format.

**Examples:**
```
[dbh:sakila:actor]> /structure
... (detailed column information)
```

### /status

Shows table status information.

**Synopsis:**
```
/status
```

**Context Required:** Table

**Description:**  
Displays status information about the table, including size, row count, and storage details.

**Examples:**
```
[dbh:sakila:actor]> /status
... (table status information)
```

### /create

Shows the CREATE TABLE statement for the selected table.

**Synopsis:**
```
/create
```

**Context Required:** Table

**Description:**  
Displays the original CREATE TABLE statement used to create the table.

**Examples:**
```
[dbh:sakila:actor]> /create
CREATE TABLE `actor` (
  `actor_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`actor_id`),
  KEY `idx_actor_last_name` (`last_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
```

### /count

Shows the number of rows in the selected table.

**Synopsis:**
```
/count
```

**Context Required:** Table

**Description:**  
Executes a COUNT(*) query to show the total number of rows in the table.

**Examples:**
```
[dbh:sakila:actor]> /count
+----------+
| COUNT(*) |
+----------+
|      200 |
+----------+
```

### /sample

Shows sample rows from the selected table.

**Synopsis:**
```
/sample [count]
```

**Context Required:** Table

**Arguments:**
- `count` - Optional number of sample rows to show (default: 10)

**Description:**  
Displays a sample of rows from the table. By default, shows 10 rows.

**Examples:**
```
[dbh:sakila:actor]> /sample 3
+----------+------------+-----------+---------------------+
| actor_id | first_name | last_name | last_update         |
+----------+------------+-----------+---------------------+
|        1 | PENELOPE   | GUINESS   | 2006-02-15 04:34:33 |
|        2 | NICK       | WAHLBERG  | 2006-02-15 04:34:33 |
|        3 | ED         | CHASE     | 2006-02-15 04:34:33 |
+----------+------------+-----------+---------------------+
```

### /primary-key

Shows the primary key columns of the selected table.

**Synopsis:**
```
/primary-key
```

**Context Required:** Table

**Description:**  
Displays information about the primary key columns of the table.

**Examples:**
```
[dbh:sakila:actor]> /primary-key
+------------+-------------+
| TABLE_NAME | COLUMN_NAME |
+------------+-------------+
| actor      | actor_id    |
+------------+-------------+
```

### /indexes

Shows all indexes on the selected table.

**Synopsis:**
```
/indexes
```

**Context Required:** Table

**Description:**  
Displays all indexes defined on the table, including column names and uniqueness.

**Examples:**
```
[dbh:sakila:actor]> /indexes
+------------+-------------------+------------+--------------+-------------+-----------+-------------+
| TABLE_NAME | INDEX_NAME        | NON_UNIQUE | SEQ_IN_INDEX | COLUMN_NAME | COLLATION | CARDINALITY |
+------------+-------------------+------------+--------------+-------------+-----------+-------------+
| actor      | PRIMARY           |          0 |            1 | actor_id    | A         |         200 |
| actor      | idx_actor_last_name |        1 |            1 | last_name   | A         |         200 |
+------------+-------------------+------------+--------------+-------------+-----------+-------------+
```

### /foreign-keys

Shows foreign key relationships for the selected table.

**Synopsis:**
```
/foreign-keys
```

**Context Required:** Table

**Description:**  
Displays all foreign key constraints defined on the table, showing the related tables and columns.

**Examples:**
```
[dbh:sakila:film_actor]> /foreign-keys
+----------------+----------------+---------------+------------------------+------------------+-----------------+
| CONSTRAINT_NAME | TABLE_NAME     | COLUMN_NAME   | REFERENCED_TABLE_NAME | REFERENCED_COLUMN | DELETE_RULE    |
+----------------+----------------+---------------+------------------------+------------------+-----------------+
| fk_film_actor_actor | film_actor | actor_id      | actor                 | actor_id         | CASCADE        |
| fk_film_actor_film  | film_actor | film_id       | film                  | film_id          | CASCADE        |
+----------------+----------------+---------------+------------------------+------------------+-----------------+
```

### /find

Searches for text in all columns of the selected table.

**Synopsis:**
```
/find <text>
```

**Context Required:** Table

**Arguments:**
- `text` - Text to search for

**Description:**  
Searches for the specified text in all columns of the table and displays matching rows.

**Examples:**
```
[dbh:sakila:actor]> /find PENELOPE
+----------+------------+-----------+---------------------+
| actor_id | first_name | last_name | last_update         |
+----------+------------+-----------+---------------------+
|        1 | PENELOPE   | GUINESS   | 2006-02-15 04:34:33 |
+----------+------------+-----------+---------------------+
```

## Database Management

### Database Schema Analysis

```bash
# Show database schema with relationships
[dbh:sakila]> /schema

# Show schema in vertical format
[dbh:sakila]> /schema v

# View character set information
[dbh:sakila]> /charset

# List available storage engines
[dbh:sakila]> /engines
```

## Database Operations

### /schema

Shows the database schema with relationships.

**Synopsis:**
```
/schema [v]
```

**Context Required:** Database

**Arguments:**
- `v` - Optional flag for vertical format

**Description:**  
Displays the schema of the current database, including tables and their relationships. The optional 'v' flag displays the information in vertical format.

**Examples:**
```
[dbh:sakila]> /schema
... (database schema information)
```

### /charset

Shows character set information for the current database.

**Synopsis:**
```
/charset
```

**Context Required:** Database

**Description:**  
Displays character set and collation information for the database and its tables.

**Examples:**
```
[dbh:sakila]> /charset
+--------------------+----------+--------------------+--------+
| SCHEMA_NAME        | CHARSET  | COLLATION          | TABLES |
+--------------------+----------+--------------------+--------+
| sakila             | utf8mb4  | utf8mb4_0900_ai_ci |     16 |
+--------------------+----------+--------------------+--------+
```

### /engines

Lists available storage engines.

**Synopsis:**
```
/engines
```

**Context Required:** None

**Description:**  
Displays all available MySQL storage engines and their properties.

**Examples:**
```
[dbh]> /engines
+--------------------+---------+----------------------------------------------------------------+
| Engine             | Support | Comment                                                        |
+--------------------+---------+----------------------------------------------------------------+
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) |
| MyISAM             | YES     | MyISAM storage engine                                          |
+--------------------+---------+----------------------------------------------------------------+
```

## Data Export and Backup

```bash
# Export query results to CSV (default format)
[dbh:sakila:film]> /export film_export.csv

# Export query results to JSON
[dbh:sakila:film]> /export --format json film_export.json

# Export query results to SQL
[dbh:sakila:film]> /export --format sql film_export.sql

# Export without headers
[dbh:sakila:film]> /export --no-headers data.csv

# Use custom delimiter
[dbh:sakila:film]> /export --delimiter "|" pipe_delimited.csv

# Backup current table to SQL file
[dbh:sakila:film]> /backup film_backup.sql

# Backup entire database
[dbh:sakila]> /backup sakila_backup.sql
```

## Export and Backup Commands

### /export

Exports query results to a file.

**Synopsis:**
```
/export [--format FORMAT] [--delimiter DELIM] [--no-headers] <file>
```

**Context Required:** Table

**Arguments:**
- `file` - Output file path
- `--format FORMAT` - Optional output format (csv, json, sql) [default: csv]
- `--delimiter DELIM` - Optional delimiter for CSV format [default: ,]
- `--no-headers` - Optional flag to exclude headers in CSV format

**Description:**  
Exports the results of the current query (as defined by columns, WHERE, ORDER BY, LIMIT) to a file in the specified format.

**Examples:**
```
[dbh:sakila:actor]> /export actor_export.csv
Exported 200 rows to actor_export.csv

[dbh:sakila:actor]> /export --format json actor_export.json
Exported 200 rows to actor_export.json

[dbh:sakila:actor]> /export --format sql --no-headers actor_export.sql
Exported 200 rows to actor_export.sql
```

### /backup

Creates a backup of the current table or database.

**Synopsis:**
```
/backup [file]
```

**Context Required:** Database or Table

**Arguments:**
- `file` - Optional output file path

**Description:**  
Creates a SQL backup of the current database or table, depending on the context. If no file is specified, suggests a default filename.

**Examples:**
```
[dbh:sakila]> /backup sakila_backup.sql
Database 'sakila' backed up to sakila_backup.sql

[dbh:sakila:actor]> /backup actor_backup.sql
Table 'actor' backed up to actor_backup.sql
```

## Administration

### User Management

```bash
# Show current MySQL user
[dbh]> /whoami

# Show information about a specific user
[dbh]> /whois john@localhost

# List all MySQL users and privileges
[dbh]> /users
```

### System Monitoring

```bash
# Show active MySQL processes
[dbh]> /processes

# View system variables
[dbh]> /variables

# Filter system variables
[dbh]> /variables innodb

# View database statistics
[dbh:sakila]> /stats

# View table statistics
[dbh:sakila:film]> /stats
```

### MySQL Interactive Mode

```bash
# Open MySQL prompt with current database
[dbh:sakila]> /prompt
# You're now in the MySQL prompt
mysql> SHOW PROCESSLIST;
mysql> exit
# Returns to dbh
```

## Administration Commands

### /whoami

Shows the current MySQL user and privileges.

**Synopsis:**
```
/whoami
```

**Context Required:** None

**Description:**  
Displays information about the current MySQL user, including username, host, and privileges.

**Examples:**
```
[dbh]> /whoami
Current MySQL User:
------------------

+----------------+----------------+
| Current User   | Effective User |
+----------------+----------------+
| dbuser@localhost | dbuser@localhost |
+----------------+----------------+

Privileges for current user:
--------------------------
+---------------------------------------------+
| Grants for dbuser@localhost                  |
+---------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO `dbuser`@`localhost` |
+---------------------------------------------+
```

### /whois

Shows information about a specific MySQL user.

**Synopsis:**
```
/whois [user]
```

**Context Required:** None

**Arguments:**
- `user` - Optional username to look up (format: username or username@host)

**Description:**  
Displays information about the specified MySQL user. If no user is specified, shows information about the current user.

**Examples:**
```
[dbh]> /whois dbuser@localhost
... (user information)
```

### /users

Shows MySQL users and privileges.

**Synopsis:**
```
/users
```

**Context Required:** None

**Description:**  
Displays a list of all MySQL users and their privileges.

**Examples:**
```
[dbh]> /users
... (user list and privileges)
```

### /processes

Shows active MySQL processes.

**Synopsis:**
```
/processes
```

**Context Required:** None

**Description:**  
Displays all active MySQL processes/connections.

**Examples:**
```
[dbh]> /processes
+----+------+----------------+------+---------+------+----------+------------------+
| Id | User | Host           | db   | Command | Time | State    | Info             |
+----+------+----------------+------+---------+------+----------+------------------+
| 43 | root | localhost      | NULL | Query   |    0 | starting | SHOW PROCESSLIST |
+----+------+----------------+------+---------+------+----------+------------------+
```

### /variables

Displays MySQL system variables.

**Synopsis:**
```
/variables [filter]
```

**Context Required:** None

**Arguments:**
- `filter` - Optional filter pattern for variable names

**Description:**  
Displays MySQL system variables. If a filter is provided, only shows variables matching the filter.

**Examples:**
```
[dbh]> /variables innodb
+---------------------------------+-----------+
| Variable_name                   | Value     |
+---------------------------------+-----------+
| innodb_buffer_pool_size         | 134217728 |
| innodb_flush_log_at_trx_commit  | 1         |
... (more innodb variables)
+---------------------------------+-----------+
```

### /stats

Shows database or table statistics.

**Synopsis:**
```
/stats
```

**Context Required:** Database or Table

**Description:**  
Displays statistics about the current database or table, depending on the context.

**Examples:**
```
[dbh:sakila]> /stats
... (database statistics)

[dbh:sakila:actor]> /stats
... (table statistics)
```

### /sql

Executes arbitrary SQL.

**Synopsis:**
```
/sql <SQL>
```

**Context Required:** None

**Arguments:**
- `SQL` - SQL statement to execute

**Description:**  
Executes the specified SQL statement. This is an alternative to direct SQL execution (without a prefix) that allows slash commands in the SQL.

**Examples:**
```
[dbh]> /sql SHOW DATABASES
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sakila             |
| sys                |
+--------------------+
```

### /prompt

Opens the MySQL prompt.

**Synopsis:**
```
/prompt
```

**Context Required:** None

**Description:**  
Opens a direct MySQL command prompt, temporarily exiting the dbh interface. When exiting the MySQL prompt, you will return to dbh.

**Examples:**
```
[dbh]> /prompt
mysql> SHOW DATABASES;
... (output)
mysql> exit
[dbh]>
```

## Shell Integration

```bash
# Execute a shell command
[dbh]> !ls -la

# View disk space
[dbh]> !df -h

# Check MySQL config file
[dbh]> !cat ~/.mylocalhost.cnf

# Launch interactive shell
[dbh]> !
$ # Do whatever shell operations you need
$ exit
# Returns to dbh with context preserved
```

## Shell Commands

### ! (Bang Command)

Executes a shell command.

**Synopsis:**
```
!<command>
```

**Context Required:** None

**Arguments:**
- `command` - Shell command to execute

**Description:**  
Executes the specified shell command. After the command completes, returns to dbh with the context preserved.

**Examples:**
```
[dbh:sakila]> !ls -la
... (directory listing)
[dbh:sakila]>
```

### ! (Interactive Shell)

Launches an interactive shell.

**Synopsis:**
```
!
```

**Context Required:** None

**Description:**  
Launches an interactive shell. When you exit the shell, you will return to dbh with the context preserved.

**Examples:**
```
[dbh:sakila]> !
$ pwd
/home/user
$ exit
[dbh:sakila]>
```

### !number (History Recall)

Executes a command from history.

**Synopsis:**
```
!<number>
```

**Context Required:** None

**Arguments:**
- `number` - History entry number to recall

**Description:**  
Recalls and executes the command at the specified position in the history.

**Examples:**
```
[dbh]> /history 5
1: /databases
2: /database sakila
3: /tables
4: /table actor
5: /describe

[dbh]> !5
... (executes the /describe command)
```

## Command History

```bash
# Show command history
[dbh]> /history

# Show specific number of history entries
[dbh]> /history 15

# Rerun command by history number
[dbh]> !23

# Use arrow keys to navigate through previous commands
# Press Up/Down arrows to cycle through history
```

## History and Help Commands

### /history

Shows command history.

**Synopsis:**
```
/history [count]
```

**Context Required:** None

**Arguments:**
- `count` - Optional number of history entries to show

**Description:**  
Displays the command history. If a count is specified, shows only that many entries.

**Examples:**
```
[dbh]> /history 5
1: /databases
2: /database sakila
3: /tables
4: /table actor
5: /describe
```

### /help

Shows help information.

**Synopsis:**
```
/help
```

**Context Required:** None

**Description:**  
Displays help information, including a list of all available commands and their descriptions.

**Examples:**
```
[dbh]> /help
dbh - MySQL Database Helper v3.7.1

Available commands:
  /help             Show this help message
  /databases        List and select a database
  /database <db>    Directly select database
  ...
```

## Configuration

```bash
# Show current configuration
[dbh]> /config show

# Create default configuration file
[dbh]> /config create

# Edit configuration in editor
[dbh]> /config edit

# Reload configuration after changes
[dbh]> /config reload
```

## Configuration Commands

### /config show

Displays current configuration settings.

**Synopsis:**
```
/config show
```

**Context Required:** None

**Description:**  
Shows the current configuration settings loaded from the configuration file.

**Examples:**
```
[dbh]> /config show
---------------- Configuration Settings ----------------
DEFAULT_PROFILE=~/.mylocalhost.cnf
DEFAULT_LIMIT=100
MAX_HISTORY=1000
```

### /config create

Creates a default configuration file.

**Synopsis:**
```
/config create
```

**Context Required:** None

**Description:**  
Creates a default configuration file at ~/.config/dbh/config with standard settings.

**Examples:**
```
[dbh]> /config create
Created configuration file at ~/.config/dbh/config
```

### /config edit

Opens the configuration file in an editor.

**Synopsis:**
```
/config edit
```

**Context Required:** None

**Description:**  
Opens the configuration file in the system's default editor (as defined by the EDITOR environment variable).

**Examples:**
```
[dbh]> /config edit
Config updated. Reload with '/config reload'.
```

### /config reload

Reloads configuration from the file.

**Synopsis:**
```
/config reload
```

**Context Required:** None

**Description:**  
Reloads the configuration from the file, applying any changes made.

**Examples:**
```
[dbh]> /config reload
Loaded 3 configuration settings
```

## Advanced Techniques

### Combining Commands for Complex Workflows

```bash
# Sequence of operations example
[dbh]> /database sakila
[dbh:sakila]> /table film
[dbh:sakila:film]> /columns title,length,rating
[dbh:sakila:film]> /where length > 120
[dbh:sakila:film]> /order length
[dbh:sakila:film]> /desc
[dbh:sakila:film]> /select
[dbh:sakila:film]> /export long_films.csv
```

### Shell Commands with Database Context

```bash
# Export data and process with shell commands
[dbh:sakila:film]> /export film_export.csv
[dbh:sakila:film]> !head film_export.csv
[dbh:sakila:film]> !wc -l film_export.csv
```

### Custom Helper Scripts

```bash
# Create a custom helper script
[dbh]> !cat > film_stats.sh << 'EOF'
#!/bin/bash
echo "Analyzing film statistics..."
mysql -h localhost -u user -ppassword sakila -e "SELECT rating, COUNT(*) FROM film GROUP BY rating"
EOF
[dbh]> !chmod +x film_stats.sh
[dbh]> !./film_stats.sh
```

## Troubleshooting

### Common Issues and Solutions

#### Connection Problems

```bash
# Problem: Cannot connect to MySQL server
# Solution: Check MySQL config file
[dbh]> !cat ~/.mylocalhost.cnf

# Solution: Verify MySQL server is running
[dbh]> !systemctl status mysql
```

#### Permission Issues

```bash
# Problem: Access denied for specific operations
# Solution: Check current user permissions
[dbh]> /whoami

# Solution: Show grants for current user
[dbh]> /whois
```

#### Error in SQL Syntax

```bash
# Problem: SQL syntax error
# Solution: Use properly escaped identifiers
[dbh:sakila]> /table `my-table-with-hyphens`
```

#### File Export Issues

```bash
# Problem: Cannot export to specified path
# Solution: Verify directory permissions
[dbh]> !ls -la /path/to/export/
```

### Getting Help

```bash
# Show available commands
[dbh]> /help

# Show program version
dbh -V
```

## Best Practices

1. **Use Context Navigation** - Let dbh handle database and table selection for you
2. **Leverage Query Building** - The interactive query building is often safer than typing direct SQL
3. **Use Tab Completion** - Many shells provide tab completion for commands
4. **Prefer Configuration Files** - Store credentials in config files instead of command line
5. **Regularly Use /state** - Check your query state before executing SELECT
6. **Export Before Destructive Operations** - Backup data before updates or deletes
7. **Combine With Shell** - Use shell integration for complex workflows
8. **Keep History Clean** - Remember history persists between sessions

---

This comprehensive usage guide and command reference covers most common operations with dbh. For technical details about the implementation, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Repository

The official repository for dbh is located at: https://github.com/Open-Technology-Foundation/dbh

## License

dbh is licensed under GNU General Public License v3.0 (GPL-3.0). See the [LICENSE](LICENSE) file for the full text.