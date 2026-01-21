#!/usr/bin/env bash
#
# Test runner for dbh
#
# Executes all test files and reports results

# Display help if requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "dbh test runner"
  echo
  echo "Usage: $0 [OPTIONS] [test_file...]"
  echo
  echo "Options:"
  echo "  -h, --help     Display this help message"
  echo "  -v, --verbose  Show more detailed output"
  echo
  echo "If no test files are specified, all tests will be run."
  echo "Available test files:"
  echo "  test_basic.sh      - Basic functionality tests"
  echo "  test_cli.sh        - CLI argument tests"
  echo "  test_functions.sh  - Helper function tests"
  echo "  test_parsing.sh    - Command parsing tests"
  echo "  test_security.sh   - Security-focused tests"
  echo "  test_state.sh      - State management tests"
  echo "  test_validation.sh - Context validation tests"
  echo
  echo "Examples:"
  echo "  $0                    # Run all tests"
  echo "  $0 test_security.sh   # Run only security tests"
  echo "  $0 -v                 # Run all tests with verbose output"
  exit 0
fi

# Check for verbose flag
VERBOSE=0
if [[ "$1" == "--verbose" || "$1" == "-v" ]]; then
  VERBOSE=1
  shift
fi

# Export verbose setting for test framework
export VERBOSE

# Ensure we're in the tests directory
cd "$(dirname "$0")" || exit 1

# Source the test framework
source ./test_framework.sh

# Determine which test files to run
test_files=("$@")
if [ ${#test_files[@]} -eq 0 ]; then
  # No specific files provided, run all tests
  test_files=(
    "test_basic.sh"
    "test_cli.sh"
    "test_functions.sh"
    "test_parsing.sh"
    "test_security.sh"
    "test_state.sh"
    "test_validation.sh"
  )
fi

# Run the specified test files
run_test_files "${test_files[@]}"

exit $?