#!/usr/bin/env bash
#
# Simple test framework for dbh
#
# This file provides common test utilities and functions for testing the dbh utility.
# It's inspired by Bats (Bash Automated Testing System) but simplified for our needs.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NOCOLOR='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Path to dbh script - adjust if needed
DBH_PATH="${DBH_PATH:-$(realpath ../dbh)}"

# Create a temporary directory for test files
TEST_DIR=$(mktemp -d)
trap 'rm -rf "${TEST_DIR}"' EXIT

# Test MySQL config for testing
TEST_CONFIG="${TEST_DIR}/test_mysql.cnf"

# Utility functions
log() {
  echo -e "${BLUE}[INFO]${NOCOLOR} $*"
}

success() {
  echo -e "${GREEN}[PASS]${NOCOLOR} $*"
}

warn() {
  echo -e "${YELLOW}[WARN]${NOCOLOR} $*"
}

error() {
  echo -e "${RED}[FAIL]${NOCOLOR} $*"
}

# Debug function that only outputs in verbose mode
debug() {
  if [[ "${VERBOSE:-0}" -eq 1 ]]; then
    echo -e "${CYAN}[DEBUG]${NOCOLOR} $*"
  fi
}

setup() {
  log "Setting up test environment..."
  
  # Create a mock MySQL config file for testing
  cat > "${TEST_CONFIG}" <<EOF
[client]
host=localhost
user=testuser
password=testpass
EOF
  
  log "Test environment ready"
}

teardown() {
  log "Cleaning up test environment..."
  # Any cleanup actions can go here
}

# Main test function
run_test() {
  local test_name="$1"
  local cmd="$2"
  local expected_status="${3:-0}"
  local expected_output="$4"
  
  TESTS_RUN=$((TESTS_RUN + 1))
  
  log "Running test: ${test_name}"
  
  # Run the command and capture output and status
  local output
  local status=0
  
  debug "Executing command: ${cmd}"
  output=$(eval "${cmd}" 2>&1) || status=$?
  debug "Command exit status: ${status}"
  
  # Check status
  if [ "${status}" -ne "${expected_status}" ]; then
    error "Test '${test_name}' failed: Expected exit status ${expected_status}, got ${status}"
    error "Command: ${cmd}"
    error "Output: ${output}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
  
  # Show command output in verbose mode
  if [[ "${VERBOSE:-0}" -eq 1 ]]; then
    debug "Command output:"
    echo -e "${CYAN}--------- OUTPUT START ---------${NOCOLOR}"
    echo "$output"
    echo -e "${CYAN}---------- OUTPUT END ----------${NOCOLOR}"
  fi
  
  # Check output if expected_output is provided
  if [ -n "${expected_output:-}" ]; then
    if ! echo "${output}" | grep -q "${expected_output}"; then
      error "Test '${test_name}' failed: Output does not contain expected string"
      error "Expected: ${expected_output}"
      error "Got: ${output}"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return 1
    fi
  fi
  
  success "Test '${test_name}' passed"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  return 0
}

# Run all tests in the given files
run_test_files() {
  local test_files=("$@")
  
  log "Starting test suite..."
  setup
  
  for file in "${test_files[@]}"; do
    log "Running tests from ${file}"
    # shellcheck disable=SC1090
    source "${file}"
  done
  
  teardown
  
  # Print summary
  echo
  echo -e "${BLUE}=== Test Summary ===${NOCOLOR}"
  echo -e "Total tests: ${TESTS_RUN}"
  echo -e "${GREEN}Passed: ${TESTS_PASSED}${NOCOLOR}"
  echo -e "${RED}Failed: ${TESTS_FAILED}${NOCOLOR}"
  
  if [ "${TESTS_FAILED}" -eq 0 ]; then
    success "All tests passed!"
    return 0
  else
    error "${TESTS_FAILED} tests failed"
    return 1
  fi
}

# Export functions that will be used by test files
export -f log success warn error run_test
export DBH_PATH TEST_CONFIG