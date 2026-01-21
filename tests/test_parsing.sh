#!/usr/bin/env bash
#
# Command parsing tests for dbh
#
# Tests input parsing, command detection, and argument extraction

# Test slash command detection
test_slash_command_detection() {
  cat > "${TEST_DIR}/slash_detect.sh" <<'EOF'
#!/usr/bin/env bash
is_slash_command() {
  [[ "$1" == /* ]]
}

# Test various inputs
is_slash_command "/help" && echo "/help: yes" || echo "/help: no"
is_slash_command "/tables" && echo "/tables: yes" || echo "/tables: no"
is_slash_command "help" && echo "help: yes" || echo "help: no"
is_slash_command "SELECT *" && echo "SELECT: yes" || echo "SELECT: no"
is_slash_command "!ls" && echo "!ls: yes" || echo "!ls: no"
is_slash_command "/" && echo "/: yes" || echo "/: no"
is_slash_command "" && echo "empty: yes" || echo "empty: no"
EOF
  chmod +x "${TEST_DIR}/slash_detect.sh"

  local output
  output=$("${TEST_DIR}/slash_detect.sh")

  local expected="/help: yes
/tables: yes
help: no
SELECT: no
!ls: no
/: yes
empty: no"

  if [[ "$output" == "$expected" ]]; then
    success "Slash command detection works correctly"
    return 0
  else
    error "Slash command detection test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Slash command detection" "test_slash_command_detection" 0 ""

# Test shell command detection
test_shell_command_detection() {
  cat > "${TEST_DIR}/shell_detect.sh" <<'EOF'
#!/usr/bin/env bash
is_shell_command() {
  [[ "$1" == !* ]]
}

# Test various inputs
is_shell_command "!ls" && echo "!ls: yes" || echo "!ls: no"
is_shell_command "!" && echo "!: yes" || echo "!: no"
is_shell_command "!123" && echo "!123: yes" || echo "!123: no"
is_shell_command "/help" && echo "/help: yes" || echo "/help: no"
is_shell_command "SELECT" && echo "SELECT: yes" || echo "SELECT: no"
is_shell_command "" && echo "empty: yes" || echo "empty: no"
EOF
  chmod +x "${TEST_DIR}/shell_detect.sh"

  local output
  output=$("${TEST_DIR}/shell_detect.sh")

  local expected="!ls: yes
!: yes
!123: yes
/help: no
SELECT: no
empty: no"

  if [[ "$output" == "$expected" ]]; then
    success "Shell command detection works correctly"
    return 0
  else
    error "Shell command detection test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Shell command detection" "test_shell_command_detection" 0 ""

# Test history recall pattern
test_history_recall_pattern() {
  cat > "${TEST_DIR}/history_pattern.sh" <<'EOF'
#!/usr/bin/env bash
is_history_recall() {
  [[ "$1" =~ ^![0-9]+$ ]]
}

# Test various inputs
is_history_recall "!1" && echo "!1: yes" || echo "!1: no"
is_history_recall "!123" && echo "!123: yes" || echo "!123: no"
is_history_recall "!0" && echo "!0: yes" || echo "!0: no"
is_history_recall "!" && echo "!: yes" || echo "!: no"
is_history_recall "!ls" && echo "!ls: yes" || echo "!ls: no"
is_history_recall "!!" && echo "!!: yes" || echo "!!: no"
is_history_recall "!1a" && echo "!1a: yes" || echo "!1a: no"
EOF
  chmod +x "${TEST_DIR}/history_pattern.sh"

  local output
  output=$("${TEST_DIR}/history_pattern.sh")

  local expected="!1: yes
!123: yes
!0: yes
!: no
!ls: no
!!: no
!1a: no"

  if [[ "$output" == "$expected" ]]; then
    success "History recall pattern works correctly"
    return 0
  else
    error "History recall pattern test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "History recall pattern matching" "test_history_recall_pattern" 0 ""

# Test command and argument extraction
test_command_extraction() {
  cat > "${TEST_DIR}/cmd_extract.sh" <<'EOF'
#!/usr/bin/env bash
extract_command() {
  local input="$1"
  # Remove leading slash
  input="${input#/}"
  # Get first word as command
  echo "${input%% *}"
}

extract_args() {
  local input="$1"
  input="${input#/}"
  local cmd="${input%% *}"
  local args="${input#"$cmd"}"
  # Trim leading space
  echo "${args# }"
}

# Test extraction
echo "cmd: [$(extract_command "/help")]"
echo "args: [$(extract_args "/help")]"
echo "cmd: [$(extract_command "/database mydb")]"
echo "args: [$(extract_args "/database mydb")]"
echo "cmd: [$(extract_command "/where id > 5")]"
echo "args: [$(extract_args "/where id > 5")]"
echo "cmd: [$(extract_command "/limit")]"
echo "args: [$(extract_args "/limit")]"
EOF
  chmod +x "${TEST_DIR}/cmd_extract.sh"

  local output
  output=$("${TEST_DIR}/cmd_extract.sh")

  local expected="cmd: [help]
args: []
cmd: [database]
args: [mydb]
cmd: [where]
args: [id > 5]
cmd: [limit]
args: []"

  if [[ "$output" == "$expected" ]]; then
    success "Command extraction works correctly"
    return 0
  else
    error "Command extraction test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Command and argument extraction" "test_command_extraction" 0 ""

# Test SQL detection (input that's neither / nor !)
test_sql_detection() {
  cat > "${TEST_DIR}/sql_detect.sh" <<'EOF'
#!/usr/bin/env bash
is_direct_sql() {
  local input="$1"
  [[ -n "$input" && "$input" != /* && "$input" != !* ]]
}

# Test various inputs
is_direct_sql "SELECT * FROM users" && echo "SELECT: yes" || echo "SELECT: no"
is_direct_sql "UPDATE users SET" && echo "UPDATE: yes" || echo "UPDATE: no"
is_direct_sql "SHOW TABLES" && echo "SHOW: yes" || echo "SHOW: no"
is_direct_sql "/help" && echo "/help: yes" || echo "/help: no"
is_direct_sql "!ls" && echo "!ls: yes" || echo "!ls: no"
is_direct_sql "" && echo "empty: yes" || echo "empty: no"
is_direct_sql "   " && echo "spaces: yes" || echo "spaces: no"
EOF
  chmod +x "${TEST_DIR}/sql_detect.sh"

  local output
  output=$("${TEST_DIR}/sql_detect.sh")

  local expected="SELECT: yes
UPDATE: yes
SHOW: yes
/help: no
!ls: no
empty: no
spaces: yes"

  if [[ "$output" == "$expected" ]]; then
    success "SQL detection works correctly"
    return 0
  else
    error "SQL detection test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Direct SQL detection" "test_sql_detection" 0 ""

# Test command alias resolution
test_command_aliases() {
  cat > "${TEST_DIR}/alias_test.sh" <<'EOF'
#!/usr/bin/env bash
resolve_alias() {
  local cmd="$1"
  case "$cmd" in
    q|quit|exit) echo "quit" ;;
    h|help|\?) echo "help" ;;
    db|database) echo "database" ;;
    t|table) echo "table" ;;
    dbs|databases) echo "databases" ;;
    tbl|tables) echo "tables" ;;
    desc|describe) echo "describe" ;;
    ..|0|back) echo "back" ;;
    *) echo "$cmd" ;;
  esac
}

# Test aliases
echo "q -> $(resolve_alias "q")"
echo "quit -> $(resolve_alias "quit")"
echo "exit -> $(resolve_alias "exit")"
echo "h -> $(resolve_alias "h")"
echo "? -> $(resolve_alias "?")"
echo "db -> $(resolve_alias "db")"
echo ".. -> $(resolve_alias "..")"
echo "0 -> $(resolve_alias "0")"
echo "unknown -> $(resolve_alias "unknown")"
EOF
  chmod +x "${TEST_DIR}/alias_test.sh"

  local output
  output=$("${TEST_DIR}/alias_test.sh")

  local expected="q -> quit
quit -> quit
exit -> quit
h -> help
? -> help
db -> database
.. -> back
0 -> back
unknown -> unknown"

  if [[ "$output" == "$expected" ]]; then
    success "Command alias resolution works correctly"
    return 0
  else
    error "Command alias test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Command alias resolution" "test_command_aliases" 0 ""

# Test destructive command detection
test_destructive_detection() {
  cat > "${TEST_DIR}/destructive_test.sh" <<'EOF'
#!/usr/bin/env bash
is_destructive() {
  local sql="${1^^}"  # Convert to uppercase
  [[ "$sql" =~ ^[[:space:]]*(DROP|DELETE|TRUNCATE|ALTER)[[:space:]] ]]
}

# Test various SQL
is_destructive "DROP TABLE users" && echo "DROP TABLE: yes" || echo "DROP TABLE: no"
is_destructive "DELETE FROM users" && echo "DELETE FROM: yes" || echo "DELETE FROM: no"
is_destructive "TRUNCATE users" && echo "TRUNCATE: yes" || echo "TRUNCATE: no"
is_destructive "ALTER TABLE users" && echo "ALTER TABLE: yes" || echo "ALTER TABLE: no"
is_destructive "SELECT * FROM users" && echo "SELECT: yes" || echo "SELECT: no"
is_destructive "INSERT INTO users" && echo "INSERT: yes" || echo "INSERT: no"
is_destructive "  DROP TABLE" && echo "  DROP: yes" || echo "  DROP: no"
is_destructive "drop table" && echo "drop (lower): yes" || echo "drop (lower): no"
EOF
  chmod +x "${TEST_DIR}/destructive_test.sh"

  local output
  output=$("${TEST_DIR}/destructive_test.sh")

  local expected="DROP TABLE: yes
DELETE FROM: yes
TRUNCATE: yes
ALTER TABLE: yes
SELECT: no
INSERT: no
  DROP: yes
drop (lower): yes"

  if [[ "$output" == "$expected" ]]; then
    success "Destructive command detection works correctly"
    return 0
  else
    error "Destructive command detection test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Destructive SQL command detection" "test_destructive_detection" 0 ""

#fin
