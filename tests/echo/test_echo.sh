#!/usr/bin/env bash

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ECHO_BIN="$PROJECT_ROOT/bin/echo"

passed=0
failed=0

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

assert_no_newline() {
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

if [[ ! -x "$ECHO_BIN" ]]; then
    printf 'ERROR: echo binary not found or not executable:\n'
    printf '       %s\n' "$ECHO_BIN"
    exit 1
fi

# --------------------------------------------------
# Basic output
# --------------------------------------------------

assert_output \
    "basic string output" \
    "hello" \
    "$ECHO_BIN" hello

assert_output \
    "multiple arguments are separated by spaces" \
    "hello world" \
    "$ECHO_BIN" hello world

assert_output \
    "empty invocation prints newline" \
    "" \
    "$ECHO_BIN"

assert_output \
    "empty argument is handled" \
    "hello " \
    "$ECHO_BIN" hello ""

# --------------------------------------------------
# -n
# --------------------------------------------------

assert_no_newline \
    "-n suppresses newline" \
    "hello" \
    "$ECHO_BIN" -n hello

assert_no_newline \
    "-nn suppresses newline" \
    "hello" \
    "$ECHO_BIN" -nn hello

assert_no_newline \
    "-nnn suppresses newline" \
    "hello" \
    "$ECHO_BIN" -nnn hello

# --------------------------------------------------
# -e / -E
# --------------------------------------------------

assert_output \
    "-e interprets newline escape" \
    $'hello\nworld' \
    "$ECHO_BIN" -e 'hello\nworld'

assert_output \
    "-E preserves newline escape literally" \
    'hello\nworld' \
    "$ECHO_BIN" -E 'hello\nworld'

assert_output \
    "default mode preserves escapes literally" \
    'hello\nworld' \
    "$ECHO_BIN" 'hello\nworld'

# --------------------------------------------------
# Option combinations
# --------------------------------------------------

assert_no_newline \
    "-ne combines -n and -e" \
    $'hello\nworld' \
    "$ECHO_BIN" -ne 'hello\nworld'

assert_no_newline \
    "-en combines -e and -n" \
    $'hello\nworld' \
    "$ECHO_BIN" -en 'hello\nworld'

assert_no_newline \
    "-n -e combines options" \
    $'hello\nworld' \
    "$ECHO_BIN" -n -e 'hello\nworld'

assert_output \
    "-e followed by -E disables escape interpretation" \
    'hello\nworld' \
    "$ECHO_BIN" -eE 'hello\nworld'

assert_output \
    "-E followed by -e enables escape interpretation" \
    $'hello\nworld' \
    "$ECHO_BIN" -Ee 'hello\nworld'

# --------------------------------------------------
# Simple escape sequences
# --------------------------------------------------

assert_output \
    "backslash escape" \
    'A\B' \
    "$ECHO_BIN" -e 'A\\B'

assert_output \
    "newline escape" \
    $'A\nB' \
    "$ECHO_BIN" -e 'A\nB'

assert_output \
    "tab escape" \
    $'A\tB' \
    "$ECHO_BIN" -e 'A\tB'

assert_output \
    "carriage return escape" \
    $'A\rB' \
    "$ECHO_BIN" -e 'A\rB'

assert_output \
    "form feed escape" \
    $'A\fB' \
    "$ECHO_BIN" -e 'A\fB'

assert_output \
    "vertical tab escape" \
    $'A\vB' \
    "$ECHO_BIN" -e 'A\vB'

assert_output \
    "alert escape" \
    $'A\aB' \
    "$ECHO_BIN" -e 'A\aB'

assert_output \
    "backspace escape" \
    $'A\bB' \
    "$ECHO_BIN" -e 'A\bB'

# ESC is ASCII 27.
expected_esc=$'A\eB'

assert_output \
    "escape character sequence" \
    "$expected_esc" \
    "$ECHO_BIN" -e 'A\eB'

# --------------------------------------------------
# Octal escapes
# --------------------------------------------------

assert_output \
    "octal escape produces A" \
    "A" \
    "$ECHO_BIN" -e '\0101'

assert_output \
    "multiple octal escapes produce Hello" \
    "Hello" \
    "$ECHO_BIN" -e '\0110\0145\0154\0154\0157'

assert_output \
    "octal and normal text can be combined" \
    "AAABC" \
    "$ECHO_BIN" -e 'AA\0101BC'

# --------------------------------------------------
# Hexadecimal escapes
# --------------------------------------------------

assert_output \
    "hex escape produces A" \
    "A" \
    "$ECHO_BIN" -e '\x41'

assert_output \
    "multiple hex escapes produce Hello" \
    "Hello" \
    "$ECHO_BIN" -e '\x48\x65\x6c\x6c\x6f'

assert_output \
    "octal and hex escapes can be combined" \
    "AAB" \
    "$ECHO_BIN" -e 'A\0101\x42'

# --------------------------------------------------
# Unknown and incomplete escapes
# --------------------------------------------------

assert_output \
    "unknown escape is preserved" \
    '\q' \
    "$ECHO_BIN" -e '\q'

assert_output \
    "incomplete hex escape is preserved" \
    '\x' \
    "$ECHO_BIN" -e '\x'

assert_output \
    "invalid hex escape is preserved" \
    '\xG1' \
    "$ECHO_BIN" -e '\xG1'

assert_output \
    "trailing backslash is preserved" \
    'hello\' \
    "$ECHO_BIN" -e 'hello\'

# --------------------------------------------------
# Argument beginning with an invalid option
# --------------------------------------------------

assert_output \
    "invalid option-like argument is treated as text" \
    '-hello' \
    "$ECHO_BIN" -hello

assert_output \
    "double-hyphen argument is treated as text" \
    '--hello' \
    "$ECHO_BIN" --hello

# --------------------------------------------------
# Final result
# --------------------------------------------------

printf '\n'
printf 'Tests passed: %d\n' "$passed"
printf 'Tests failed: %d\n' "$failed"

if (( failed > 0 )); then
    exit 1
fi

exit 0
