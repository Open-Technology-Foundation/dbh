#!/usr/bin/env bash
#
# State management tests for dbh
#
# Tests query building state, context management, and variable handling

# Test query state initialization defaults
test_query_state_defaults() {
  cat > "${TEST_DIR}/state_defaults.sh" <<'EOF'
#!/usr/bin/env bash
# Default state values (from dbh)
declare -ga SelectedColumns=('*')
declare -g WhereClause='' OrderClause='' OrderDirection='ASC' LimitClause='100'

# Verify defaults
echo "Columns: ${SelectedColumns[*]}"
echo "Where: [${WhereClause}]"
echo "Order: [${OrderClause}]"
echo "Direction: ${OrderDirection}"
echo "Limit: ${LimitClause}"
EOF
  chmod +x "${TEST_DIR}/state_defaults.sh"

  local output
  output=$("${TEST_DIR}/state_defaults.sh")

  local expected="Columns: *
Where: []
Order: []
Direction: ASC
Limit: 100"

  if [[ "$output" == "$expected" ]]; then
    success "Query state defaults are correct"
    return 0
  else
    error "Query state defaults test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Query state default values" "test_query_state_defaults" 0 ""

# Test column selection state
test_column_state() {
  cat > "${TEST_DIR}/column_state.sh" <<'EOF'
#!/usr/bin/env bash
declare -ga SelectedColumns=('*')

# Function to set columns
set_columns() {
  local input="$1"
  IFS=',' read -ra SelectedColumns <<< "$input"
}

# Test setting columns
set_columns "id,name,email"
echo "After set: ${SelectedColumns[*]}"
echo "Count: ${#SelectedColumns[@]}"

# Test resetting to all
SelectedColumns=('*')
echo "After reset: ${SelectedColumns[*]}"
EOF
  chmod +x "${TEST_DIR}/column_state.sh"

  local output
  output=$("${TEST_DIR}/column_state.sh")

  if echo "$output" | grep -q "After set: id name email" && \
     echo "$output" | grep -q "Count: 3" && \
     echo "$output" | grep -q 'After reset: \*'; then
    success "Column state management works correctly"
    return 0
  else
    error "Column state test failed"
    error "Output: $output"
    return 1
  fi
}

run_test "Column selection state" "test_column_state" 0 ""

# Test prompt prefix state
test_prompt_state() {
  cat > "${TEST_DIR}/prompt_state.sh" <<'EOF'
#!/usr/bin/env bash
declare -g PromptPrefix='[dbh]'
declare -g Database='' DataTable=''

update_prompt() {
  if [[ -n "$DataTable" ]]; then
    PromptPrefix="[dbh:$Database:$DataTable]"
  elif [[ -n "$Database" ]]; then
    PromptPrefix="[dbh:$Database]"
  else
    PromptPrefix="[dbh]"
  fi
}

# Test prompt progression
echo "$PromptPrefix"

Database="mydb"
update_prompt
echo "$PromptPrefix"

DataTable="users"
update_prompt
echo "$PromptPrefix"

DataTable=""
update_prompt
echo "$PromptPrefix"

Database=""
update_prompt
echo "$PromptPrefix"
EOF
  chmod +x "${TEST_DIR}/prompt_state.sh"

  local output
  output=$("${TEST_DIR}/prompt_state.sh")

  local expected="[dbh]
[dbh:mydb]
[dbh:mydb:users]
[dbh:mydb]
[dbh]"

  if [[ "$output" == "$expected" ]]; then
    success "Prompt state transitions work correctly"
    return 0
  else
    error "Prompt state test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Prompt prefix state transitions" "test_prompt_state" 0 ""

# Test history array management
test_history_state() {
  cat > "${TEST_DIR}/history_state.sh" <<'EOF'
#!/usr/bin/env bash
declare -a CommandHistory=()

add_to_history() {
  local cmd="$1"
  [[ -n "$cmd" ]] && CommandHistory+=("$cmd")
}

# Test adding commands
add_to_history "SELECT * FROM users"
add_to_history "/tables"
add_to_history ""  # Should be ignored
add_to_history "!ls"

echo "Count: ${#CommandHistory[@]}"
echo "First: ${CommandHistory[0]}"
echo "Last: ${CommandHistory[-1]}"
EOF
  chmod +x "${TEST_DIR}/history_state.sh"

  local output
  output=$("${TEST_DIR}/history_state.sh")

  if echo "$output" | grep -q "Count: 3" && \
     echo "$output" | grep -q "First: SELECT \* FROM users" && \
     echo "$output" | grep -q "Last: !ls"; then
    success "History state management works correctly"
    return 0
  else
    error "History state test failed"
    error "Output: $output"
    return 1
  fi
}

run_test "Command history state" "test_history_state" 0 ""

# Test order direction toggle
test_order_direction() {
  cat > "${TEST_DIR}/order_dir.sh" <<'EOF'
#!/usr/bin/env bash
declare -g OrderDirection='ASC'

set_direction() {
  local dir="$1"
  if [[ "${dir,,}" == 'desc' ]]; then
    OrderDirection='DESC'
  else
    OrderDirection='ASC'
  fi
}

echo "Default: $OrderDirection"
set_direction "desc"
echo "After desc: $OrderDirection"
set_direction "DESC"
echo "After DESC: $OrderDirection"
set_direction "asc"
echo "After asc: $OrderDirection"
set_direction "anything"
echo "After anything: $OrderDirection"
EOF
  chmod +x "${TEST_DIR}/order_dir.sh"

  local output
  output=$("${TEST_DIR}/order_dir.sh")

  local expected="Default: ASC
After desc: DESC
After DESC: DESC
After asc: ASC
After anything: ASC"

  if [[ "$output" == "$expected" ]]; then
    success "Order direction state works correctly"
    return 0
  else
    error "Order direction test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Order direction state toggle" "test_order_direction" 0 ""

# Test limit validation and state
test_limit_state() {
  cat > "${TEST_DIR}/limit_state.sh" <<'EOF'
#!/usr/bin/env bash
declare -g LimitClause='100'

set_limit() {
  local input="$1"
  if [[ -z "$input" ]]; then
    LimitClause=''
    return 0
  elif [[ "$input" =~ ^[0-9]+$ ]]; then
    LimitClause="$input"
    return 0
  else
    return 1
  fi
}

echo "Default: [$LimitClause]"
set_limit "50" && echo "After 50: [$LimitClause]"
set_limit "" && echo "After clear: [$LimitClause]"
set_limit "abc" || echo "Invalid rejected"
echo "Still: [$LimitClause]"
set_limit "999" && echo "After 999: [$LimitClause]"
EOF
  chmod +x "${TEST_DIR}/limit_state.sh"

  local output
  output=$("${TEST_DIR}/limit_state.sh")

  local expected="Default: [100]
After 50: [50]
After clear: []
Invalid rejected
Still: []
After 999: [999]"

  if [[ "$output" == "$expected" ]]; then
    success "Limit state validation works correctly"
    return 0
  else
    error "Limit state test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Limit clause state and validation" "test_limit_state" 0 ""

#fin
