#!/usr/bin/env bash
#
# Validation function tests for dbh
#
# Tests the helper functions that validate database and table context

# Test the require_database function
test_require_database() {
  # Create a test script with our implementation
  cat > "${TEST_DIR}/require_database_test.sh" <<'EOF'
#!/usr/bin/env bash
# Mock error function
error() {
  echo "ERROR: $*" >&2
}

# Implementation of require_database
require_database() {
  local custom_error="$1"
  
  if [[ -z "$Database" ]]; then
    error "${custom_error:-"No database selected. Use /database first."}"
    return 1
  fi
  
  return 0
}

# Test with no database selected
Database=""
require_database
echo "Return code: $?"

# Test with database selected
Database="test_db"
require_database
echo "Return code: $?"

# Test with custom error message
Database=""
require_database "Custom error message"
echo "Return code: $?"
EOF
  chmod +x "${TEST_DIR}/require_database_test.sh"
  
  # Run the test
  local output
  output=$("${TEST_DIR}/require_database_test.sh" 2>&1)
  
  # Check expected outputs
  local expected_error="ERROR: No database selected. Use /database first."
  local expected_custom="ERROR: Custom error message"
  
  if echo "$output" | grep -q "$expected_error" && 
     echo "$output" | grep -q "Return code: 1" &&
     echo "$output" | grep -q "Return code: 0" &&
     echo "$output" | grep -q "$expected_custom"; then
    success "require_database function works correctly"
    return 0
  else
    error "require_database test failed"
    error "Output: $output"
    return 1
  fi
}

# Test the require_table function
test_require_table() {
  # Create a test script with our implementation
  cat > "${TEST_DIR}/require_table_test.sh" <<'EOF'
#!/usr/bin/env bash
# Mock error function
error() {
  echo "ERROR: $*" >&2
}

# Implementation of require_database and require_table
require_database() {
  local custom_error="$1"
  
  if [[ -z "$Database" ]]; then
    error "${custom_error:-"No database selected. Use /database first."}"
    return 1
  fi
  
  return 0
}

require_table() {
  local custom_error="$1"
  
  # First check database context
  require_database || return 1
  
  if [[ -z "$DataTable" ]]; then
    error "${custom_error:-"No table selected. Use /table first."}"
    return 1
  fi
  
  return 0
}

# Test with no database and no table
Database=""
DataTable=""
require_table
echo "Return code: $?"

# Test with database but no table
Database="test_db"
DataTable=""
require_table
echo "Return code: $?"

# Test with database and table
Database="test_db"
DataTable="test_table"
require_table
echo "Return code: $?"

# Test with custom error message
Database="test_db"
DataTable=""
require_table "Custom table error"
echo "Return code: $?"
EOF
  chmod +x "${TEST_DIR}/require_table_test.sh"
  
  # Run the test
  local output
  output=$("${TEST_DIR}/require_table_test.sh" 2>&1)
  
  # Check expected outputs
  local expected_db_error="ERROR: No database selected. Use /database first."
  local expected_table_error="ERROR: No table selected. Use /table first."
  local expected_custom="ERROR: Custom table error"
  
  if echo "$output" | grep -q "$expected_db_error" && 
     echo "$output" | grep -q "$expected_table_error" &&
     echo "$output" | grep -q "Return code: 0" &&
     echo "$output" | grep -q "$expected_custom"; then
    success "require_table function works correctly"
    return 0
  else
    error "require_table test failed"
    error "Output: $output"
    return 1
  fi
}

# Run the validation function tests
run_test "Database context validation" "test_require_database" 0 ""
run_test "Table context validation" "test_require_table" 0 ""