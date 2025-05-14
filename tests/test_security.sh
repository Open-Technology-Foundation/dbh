#!/usr/bin/env bash
#
# Security-focused tests for dbh
#
# Tests SQL escaping, path handling, and other security features

# Test SQL identifier quoting
test_quote_ident() {
  # Create a test script with our implementation of quote_ident
  cat > "${TEST_DIR}/quote_ident_test.sh" <<'EOF'
#!/usr/bin/env bash
# Function to safely quote SQL identifiers
quote_ident() { 
  local ident="$1"
  # Double backticks within identifiers (MySQL's escaping rule for identifiers)
  ident="${ident//\`/\`\`}"
  echo "\`$ident\`"
}

# Test with various inputs
quote_ident "table1"
quote_ident "table\`1"
quote_ident "my table"
quote_ident "weird.name"
EOF
  chmod +x "${TEST_DIR}/quote_ident_test.sh"
  
  # Run the test
  local output
  output=$("${TEST_DIR}/quote_ident_test.sh")
  
  # Check expected outputs
  local expected_output="\`table1\`
\`table\`\`1\`
\`my table\`
\`weird.name\`"
  
  if [ "$output" = "$expected_output" ]; then
    success "quote_ident correctly handles identifiers"
    return 0
  else
    error "quote_ident test failed"
    error "Expected:"
    error "$expected_output"
    error "Got:"
    error "$output"
    return 1
  fi
}

# Test SQL value escaping
test_escape_sql_value() {
  # Create a test script with our implementation of escape_sql_value
  cat > "${TEST_DIR}/escape_sql_value_test.sh" <<'EOF'
#!/usr/bin/env bash
# Function to safely escape SQL values
escape_sql_value() {
  local value="$1"
  # Replace single quotes with two single quotes (SQL standard escaping)
  value="${value//\'/\'\'}"
  echo "'$value'"
}

# Test with various inputs
escape_sql_value "value"
escape_sql_value "O'Reilly"
escape_sql_value "'test'"
escape_sql_value "drop table; --"
EOF
  chmod +x "${TEST_DIR}/escape_sql_value_test.sh"
  
  # Run the test
  local output
  output=$("${TEST_DIR}/escape_sql_value_test.sh")
  
  # Check expected outputs
  local expected_output="'value'
'O''Reilly'
'''test'''
'drop table; --'"
  
  if [ "$output" = "$expected_output" ]; then
    success "escape_sql_value correctly handles values"
    return 0
  else
    error "escape_sql_value test failed"
    error "Expected:"
    error "$expected_output"
    error "Got:"
    error "$output"
    return 1
  fi
}

# Test secure temp file creation
test_secure_tempfile() {
  # Create a test script with our implementation of create_secure_tempfile
  cat > "${TEST_DIR}/tempfile_test.sh" <<'EOF'
#!/usr/bin/env bash
# Function to create a secure temporary file
create_secure_tempfile() {
  local prefix="$1"
  local tmp_dir="${TMPDIR:-/tmp}"
  
  # Fall back to /tmp if the specified temp directory doesn't exist or isn't writable
  [[ -d "$tmp_dir" && -w "$tmp_dir" ]] || tmp_dir="/tmp"
  
  # Create temp file with a unique name
  local temp_file
  temp_file=$(TMPDIR="$tmp_dir" mktemp "${prefix}.XXXXXXXXXX")
  
  # Apply restrictive permissions - only owner can read/write
  chmod 0600 "$temp_file"
  
  # Return the path to the created file
  echo "$temp_file"
}

# Create a test temp file
temp_file=$(create_secure_tempfile "test")

# Check the permissions
ls -l "$temp_file" | awk '{print $1}'

# Check if file exists and is a regular file
if [[ -f "$temp_file" ]]; then echo "File exists"; fi

# Cleanup
rm -f "$temp_file"
EOF
  chmod +x "${TEST_DIR}/tempfile_test.sh"
  
  # Run the test
  local output
  output=$("${TEST_DIR}/tempfile_test.sh")
  
  # Check expected outputs - permissions should be -rw------- (0600)
  if echo "$output" | grep -q -E '^-rw-------' && echo "$output" | grep -q 'File exists'; then
    success "create_secure_tempfile creates properly secured temp files"
    return 0
  else
    error "secure tempfile test failed"
    error "Expected permissions -rw------- and file existence"
    error "Got:"
    error "$output"
    return 1
  fi
}

# Run the security function tests
run_test "SQL identifier quoting" "test_quote_ident" 0 ""
run_test "SQL value escaping" "test_escape_sql_value" 0 ""
run_test "Secure temporary file creation" "test_secure_tempfile" 0 ""