#!/usr/bin/env bash
#
# CLI argument tests for dbh
#
# Tests command-line options, flags, and argument handling

# Test version flag
run_test "Version flag short" \
  "${DBH_PATH} -V" \
  0 \
  "dbh 3.7.1"

run_test "Version flag long" \
  "${DBH_PATH} --version" \
  0 \
  "dbh 3.7.1"

# Test help flag variants
run_test "Help flag short" \
  "${DBH_PATH} -h" \
  0 \
  "Usage:"

run_test "Help flag long" \
  "${DBH_PATH} --help" \
  0 \
  "Usage:"

# Test that help shows all major sections
test_help_sections() {
  local output
  output=$("${DBH_PATH}" --help 2>&1)

  local sections=(
    "Usage:"
    "Options:"
    "Command Types:"
    "Database Navigation:"
    "Query Building:"
    "Table Operations:"
    "Database Operations:"
    "Administration:"
    "Shell Access:"
    "Examples:"
  )

  local missing=()
  for section in "${sections[@]}"; do
    if ! echo "$output" | grep -q "$section"; then
      missing+=("$section")
    fi
  done

  if ((${#missing[@]} == 0)); then
    success "Help output contains all expected sections"
    return 0
  else
    error "Help output missing sections: ${missing[*]}"
    return 1
  fi
}

run_test "Help contains all sections" "test_help_sections" 0 ""

# Test invalid profile path
test_invalid_profile() {
  local output
  local status=0
  output=$("${DBH_PATH}" -p /nonexistent/path/profile.cnf 2>&1) || status=$?

  if ((status != 0)) && echo "$output" | grep -qi "profile\|not found\|could not"; then
    success "Invalid profile correctly rejected"
    return 0
  else
    error "Invalid profile should fail with error message"
    error "Status: $status, Output: $output"
    return 1
  fi
}

run_test "Invalid profile path rejected" "test_invalid_profile" 0 ""

# Test unknown option handling
test_unknown_option() {
  local output
  local status=0
  output=$("${DBH_PATH}" --unknown-option 2>&1) || status=$?

  # Should either show error or help (graceful handling)
  if ((status != 0)) || echo "$output" | grep -qi "unknown\|invalid\|usage\|help"; then
    success "Unknown option handled gracefully"
    return 0
  else
    error "Unknown option should be rejected or show help"
    return 1
  fi
}

run_test "Unknown option handling" "test_unknown_option" 0 ""

#fin
