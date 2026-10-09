#!/usr/bin/env bash

set -u

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PWD_BIN="$PROJECT_ROOT/bin/pwd"

passed=0
failed=0

# ----------------------------------------------------------------------
# Test helpers
# ----------------------------------------------------------------------

pass() {
    printf 'PASS: %s\n' "$1"
    passed=$((passed + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    failed=$((failed + 1))
}

assert_output() {
    local description="$1"
    local expected="$2"
    shift 2

    local actual
    actual=$("$@" 2>/dev/null)

    if [[ "$actual" == "$expected" ]]; then
        pass "$description"
    else
        fail "$description"
        printf '  expected: %q\n' "$expected"
        printf '  actual:   %q\n' "$actual"
    fi
}

assert_exit_failure() {
    local description="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        fail "$description"
    else
        pass "$description"
    fi
}

# ----------------------------------------------------------------------
# Prerequisites
# ----------------------------------------------------------------------

if [[ ! -x "$PWD_BIN" ]]; then
    printf 'ERROR: pwd binary not found or not executable:\n'
    printf '       %s\n' "$PWD_BIN"
    exit 1
fi

# ----------------------------------------------------------------------
# Save original environment
# ----------------------------------------------------------------------

original_dir="$(pwd)"
original_pwd="${PWD-}"

# ----------------------------------------------------------------------
# Basic behavior
# ----------------------------------------------------------------------

expected_pwd="$original_dir"

assert_output \
    "default pwd prints physical working directory" \
    "$expected_pwd" \
    "$PWD_BIN"

assert_output \
    "pwd -P prints physical working directory" \
    "$expected_pwd" \
    "$PWD_BIN" -P

assert_output \
    "pwd -L prints logical working directory" \
    "$expected_pwd" \
    "$PWD_BIN" -L

# ----------------------------------------------------------------------
# Option parsing
# ----------------------------------------------------------------------

assert_output \
    "pwd -LP uses physical mode" \
    "$expected_pwd" \
    "$PWD_BIN" -LP

assert_output \
    "pwd -PL uses logical mode" \
    "$expected_pwd" \
    "$PWD_BIN" -PL

assert_exit_failure \
    "invalid option returns non-zero status" \
    "$PWD_BIN" -X

# ----------------------------------------------------------------------
# Symlink behavior
# ----------------------------------------------------------------------

test_dir="$(mktemp -d)"

cleanup() {
    cd "$original_dir" 2>/dev/null || true

    if [[ -n "$original_pwd" ]]; then
        export PWD="$original_pwd"
    else
        unset PWD
    fi

    rm -rf "$test_dir"
}

trap cleanup EXIT

real_dir="$test_dir/real"
link_dir="$test_dir/link"

mkdir "$real_dir"
ln -s "$real_dir" "$link_dir"

cd "$link_dir" || {
    printf 'ERROR: failed to enter symlink test directory\n'
    exit 1
}

logical_path="$link_dir"
physical_path="$real_dir"

assert_output \
    "pwd -L preserves symlink path" \
    "$logical_path" \
    "$PWD_BIN" -L

assert_output \
    "pwd -P resolves symlink path" \
    "$physical_path" \
    "$PWD_BIN" -P

assert_output \
    "default pwd uses physical path" \
    "$physical_path" \
    "$PWD_BIN"

assert_output \
    "pwd -LP uses physical path" \
    "$physical_path" \
    "$PWD_BIN" -LP

assert_output \
    "pwd -PL uses logical path" \
    "$logical_path" \
    "$PWD_BIN" -PL

# ----------------------------------------------------------------------
# PWD validation
# ----------------------------------------------------------------------

export PWD="$logical_path"

assert_output \
    "valid PWD is used by pwd -L" \
    "$logical_path" \
    "$PWD_BIN" -L

export PWD="/fake/path"

assert_output \
    "invalid PWD falls back to physical path" \
    "$physical_path" \
    "$PWD_BIN" -L

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------

printf '\n'
printf 'Tests passed: %d\n' "$passed"
printf 'Tests failed: %d\n' "$failed"

if (( failed > 0 )); then
    exit 1
fi

exit 0
