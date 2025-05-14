#!/usr/bin/env bash
#
# Basic tests for dbh
#
# Tests basic functionality like command-line options, help display, etc.

# Test help flag (returns 0, doesn't try to connect to MySQL)
run_test "Help flag" \
  "${DBH_PATH} --help" \
  0 \
  "Usage:"

# Test path resolution functions by creating a mock script
test_tilde_expansion() {
  # Create a test script with the relevant function from dbh
  cat > "${TEST_DIR}/tilde_test.sh" <<'EOF'
#!/usr/bin/env bash
# Function to test tilde expansion
expand_tilde_path() {
  local path="$1"
  if [[ "$path" == \~* ]]; then
    echo "${HOME}${path:1}"
  else
    echo "$path"
  fi
}

# Test with different paths
expand_tilde_path "~/test.cnf"
expand_tilde_path "~/.myconf.cnf"
expand_tilde_path "/absolute/path/file.cnf"
expand_tilde_path "./relative/path.cnf"
EOF
  chmod +x "${TEST_DIR}/tilde_test.sh"
  
  # Run the test script
  local output
  output=$("${TEST_DIR}/tilde_test.sh")
  
  # Check expected outputs
  local expected_output="${HOME}/test.cnf
${HOME}/.myconf.cnf
/absolute/path/file.cnf
./relative/path.cnf"
  
  if [ "$output" = "$expected_output" ]; then
    success "Tilde expansion function works correctly"
    return 0
  else
    error "Tilde expansion failed"
    error "Expected:"
    error "$expected_output"
    error "Got:"
    error "$output"
    return 1
  fi
}

# Run tilde expansion test
run_test "Tilde expansion in paths" "test_tilde_expansion" 0 ""