#!/usr/bin/env bash
#
# Helper function tests for dbh
#
# Tests utility functions like trim, messaging, and SQL helpers

# Test trim function
test_trim() {
  cat > "${TEST_DIR}/trim_test.sh" <<'EOF'
#!/usr/bin/env bash
# Function to trim whitespace
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

# Test various inputs
echo "[$(trim "  hello  ")]"
echo "[$(trim "	tab	")]"
echo "[$(trim "  spaces and tabs	")]"
echo "[$(trim "no_trim")]"
echo "[$(trim "   ")]"
echo "[$(trim "")]"
echo "[$(trim "  multi  word  ")]"
EOF
  chmod +x "${TEST_DIR}/trim_test.sh"

  local output
  output=$("${TEST_DIR}/trim_test.sh")

  local expected="[hello]
[tab]
[spaces and tabs]
[no_trim]
[]
[]
[multi  word]"

  if [[ "$output" == "$expected" ]]; then
    success "trim function handles all whitespace cases correctly"
    return 0
  else
    error "trim test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Trim whitespace function" "test_trim" 0 ""

# Test SQL injection prevention in quote_ident with edge cases
test_quote_ident_edge_cases() {
  cat > "${TEST_DIR}/quote_ident_edge.sh" <<'EOF'
#!/usr/bin/env bash
quote_ident() {
  local ident="$1"
  ident="${ident//\`/\`\`}"
  echo "\`$ident\`"
}

# Edge cases
quote_ident ""
quote_ident "\`\`\`"
quote_ident "table; DROP DATABASE"
quote_ident "table\`; DROP--"
quote_ident "日本語テーブル"
quote_ident "table_name_with_123"
EOF
  chmod +x "${TEST_DIR}/quote_ident_edge.sh"

  local output
  output=$("${TEST_DIR}/quote_ident_edge.sh")

  local expected="\`\`
\`\`\`\`\`\`\`\`
\`table; DROP DATABASE\`
\`table\`\`; DROP--\`
\`日本語テーブル\`
\`table_name_with_123\`"

  if [[ "$output" == "$expected" ]]; then
    success "quote_ident handles edge cases correctly"
    return 0
  else
    error "quote_ident edge case test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "SQL identifier quoting edge cases" "test_quote_ident_edge_cases" 0 ""

# Test SQL value escaping with edge cases
test_escape_sql_edge_cases() {
  cat > "${TEST_DIR}/escape_sql_edge.sh" <<'EOF'
#!/usr/bin/env bash
escape_sql_value() {
  local value="$1"
  value="${value//\'/\'\'}"
  echo "'$value'"
}

# Edge cases
escape_sql_value ""
escape_sql_value "'''"
escape_sql_value "'; DROP TABLE users; --"
escape_sql_value "NULL"
escape_sql_value "1 OR 1=1"
escape_sql_value "value with
newline"
EOF
  chmod +x "${TEST_DIR}/escape_sql_edge.sh"

  local output
  output=$("${TEST_DIR}/escape_sql_edge.sh")

  local expected="''
''''''''
'''; DROP TABLE users; --'
'NULL'
'1 OR 1=1'
'value with
newline'"

  if [[ "$output" == "$expected" ]]; then
    success "escape_sql_value handles edge cases correctly"
    return 0
  else
    error "escape_sql_value edge case test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "SQL value escaping edge cases" "test_escape_sql_edge_cases" 0 ""

# Test is_valid_integer function pattern
test_integer_validation() {
  cat > "${TEST_DIR}/int_test.sh" <<'EOF'
#!/usr/bin/env bash
is_valid_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Test various inputs
is_valid_integer "123" && echo "123: valid" || echo "123: invalid"
is_valid_integer "0" && echo "0: valid" || echo "0: invalid"
is_valid_integer "-5" && echo "-5: valid" || echo "-5: invalid"
is_valid_integer "12.5" && echo "12.5: valid" || echo "12.5: invalid"
is_valid_integer "abc" && echo "abc: valid" || echo "abc: invalid"
is_valid_integer "" && echo "empty: valid" || echo "empty: invalid"
is_valid_integer "12 34" && echo "space: valid" || echo "space: invalid"
is_valid_integer "999999999" && echo "large: valid" || echo "large: invalid"
EOF
  chmod +x "${TEST_DIR}/int_test.sh"

  local output
  output=$("${TEST_DIR}/int_test.sh")

  local expected="123: valid
0: valid
-5: invalid
12.5: invalid
abc: invalid
empty: invalid
space: invalid
large: valid"

  if [[ "$output" == "$expected" ]]; then
    success "Integer validation works correctly"
    return 0
  else
    error "Integer validation test failed"
    error "Expected: $expected"
    error "Got: $output"
    return 1
  fi
}

run_test "Integer validation pattern" "test_integer_validation" 0 ""

# Test path normalization (simple ~ expansion for current user)
test_path_handling() {
  cat > "${TEST_DIR}/path_test.sh" <<'EOF'
#!/usr/bin/env bash
expand_tilde_path() {
  local path="$1"
  if [[ "$path" == \~* ]]; then
    echo "${HOME}${path:1}"
  else
    echo "$path"
  fi
}

# Test cases for simple tilde expansion
expand_tilde_path "~"
expand_tilde_path "~/"
expand_tilde_path "~/.config"
expand_tilde_path "/absolute/path"
expand_tilde_path "./relative/path"
EOF
  chmod +x "${TEST_DIR}/path_test.sh"

  local output
  output=$("${TEST_DIR}/path_test.sh")

  # Expected: ~ expands to HOME, absolute/relative paths stay unchanged
  if echo "$output" | grep -q "^${HOME}$" && \
     echo "$output" | grep -q "^${HOME}/$" && \
     echo "$output" | grep -q "^${HOME}/.config$" && \
     echo "$output" | grep -q "^/absolute/path$" && \
     echo "$output" | grep -q "^\./relative/path$"; then
    success "Path handling works correctly"
    return 0
  else
    error "Path handling test failed"
    error "Output: $output"
    return 1
  fi
}

run_test "Path expansion handling" "test_path_handling" 0 ""

#fin
