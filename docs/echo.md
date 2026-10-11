# echo

## Overview

`echo` is a command-line utility that writes its arguments to standard output.

This project implements a simplified Unix/Linux-style `echo` utility in C as part of the `unix-utilities-from-scratch` project.

The implementation was developed to understand:

- Command-line argument parsing
- Option handling
- C strings and character processing
- Escape-sequence interpretation
- Octal and hexadecimal conversion
- Standard output
- Linux/Unix command behavior

---

## Usage

```text
./bin/echo [options] [arguments...]
```

Examples:

```bash
./bin/echo hello
./bin/echo hello world
./bin/echo -n hello
./bin/echo -e 'hello\nworld'
./bin/echo -E 'hello\nworld'
```

---

## Basic Behavior

Arguments are printed to standard output with a single space between consecutive arguments.

A newline is printed after the final argument by default.

Example:

```bash
./bin/echo hello world
```

Output:

```text
hello world
```

When no arguments are supplied:

```bash
./bin/echo
```

the program prints a newline.

---

## Options

The implementation supports three options.

### `-n`

Suppresses the trailing newline.

```bash
./bin/echo -n hello
```

Output:

```text
hello
```

The option can also be repeated or combined:

```bash
./bin/echo -nn hello
./bin/echo -nnn hello
./bin/echo -ne 'hello\nworld'
```

---

### `-e`

Enables interpretation of backslash escape sequences.

```bash
./bin/echo -e 'hello\nworld'
```

Output:

```text
hello
world
```

---

### `-E`

Disables interpretation of backslash escape sequences.

This is also the default behavior.

```bash
./bin/echo -E 'hello\nworld'
```

Output:

```text
hello\nworld
```

Option ordering is respected. For example:

```bash
./bin/echo -eE 'hello\nworld'
```

leaves escape interpretation disabled, while:

```bash
./bin/echo -Ee 'hello\nworld'
```

enables it.

---

## Escape Sequences

When `-e` is enabled, the following escape sequences are interpreted.

| Escape  | Meaning                                               |
| ------- | ----------------------------------------------------- |
| `\\`    | Backslash                                             |
| `\a`    | Alert/bell                                            |
| `\b`    | Backspace                                             |
| `\e`    | Escape character (ASCII 27)                           |
| `\f`    | Form feed                                             |
| `\n`    | Newline                                               |
| `\r`    | Carriage return                                       |
| `\t`    | Horizontal tab                                        |
| `\v`    | Vertical tab                                          |
| `\0NNN` | Character represented by up to three octal digits     |
| `\xHH`  | Character represented by up to two hexadecimal digits |

Examples:

```bash
./bin/echo -e 'A\tB'
```

```text
A    B
```

```bash
./bin/echo -e 'A\nB'
```

```text
A
B
```

---

## Octal Escapes

The implementation supports octal character escapes in the form:

```text
\0NNN
```

where `NNN` contains up to three octal digits.

For example:

```bash
./bin/echo -e '\0101'
```

produces:

```text
A
```

Multiple octal escapes can be combined:

```bash
./bin/echo -e '\0110\0145\0154\0154\0157'
```

produces:

```text
Hello
```

The implementation converts each octal digit using base 8 arithmetic.

---

## Hexadecimal Escapes

The implementation supports hexadecimal character escapes in the form:

```text
\xHH
```

where `HH` contains up to two hexadecimal digits.

Both uppercase and lowercase hexadecimal digits are accepted.

Examples:

```bash
./bin/echo -e '\x41'
```

produces:

```text
A
```

and:

```bash
./bin/echo -e '\x48\x65\x6c\x6c\x6f'
```

produces:

```text
Hello
```

Octal and hexadecimal escapes can also be combined:

```bash
./bin/echo -e 'A\0101\x42'
```

produces:

```text
AAB
```

---

## Unknown Escape Sequences

Unknown escape sequences are preserved rather than discarded.

For example:

```bash
./bin/echo -e '\q'
```

produces:

```text
\q
```

This behavior is implemented through the `default` branch of the escape-sequence parser.

---

## Incomplete Escape Sequences

Incomplete or invalid hexadecimal escapes are preserved.

Examples:

```bash
./bin/echo -e '\x'
```

produces:

```text
\x
```

and:

```bash
./bin/echo -e '\xG1'
```

produces:

```text
\xG1
```

A trailing backslash is also preserved:

```bash
./bin/echo -e 'hello\'
```

produces:

```text
hello\
```

---

## Option Parsing

Unlike utilities such as `pwd`, this implementation does not use `getopt()`.

`echo` requires custom option parsing because options can be clustered:

```text
-n
-nn
-ne
-en
-eE
```

Each character following the leading `-` is inspected individually.

Recognized option characters are:

```text
n
e
E
```

If an unrecognized option character is encountered, the argument is treated as normal output rather than being consumed as an option.

For example:

```bash
./bin/echo -hello
```

produces:

```text
-hello
```

Similarly:

```bash
./bin/echo --hello
```

produces:

```text
--hello
```

---

## Implementation

The implementation is contained in:

```text
src/echo/echo.c
```

The program has two major parts.

### `print_escaped()`

```c
void print_escaped(const char *text)
```

This function processes an individual argument character-by-character.

Normal characters are printed directly.

When a backslash is encountered, the following character determines which escape sequence should be produced.

Simple escapes are handled using a `switch` statement.

Octal and hexadecimal escapes require additional parsing because multiple characters can represent a single output byte.

---

### `main()`

`main()` is responsible for:

1. Initializing the default behavior.
2. Parsing `-n`, `-e`, and `-E`.
3. Determining the first actual argument.
4. Printing arguments separated by spaces.
5. Calling `print_escaped()` when escape interpretation is enabled.
6. Printing the final newline unless `-n` was specified.

---

## Compilation

The project uses the root `Makefile`.

Build all currently implemented utilities with:

```bash
make
```

The resulting binaries are placed in:

```text
bin/
```

The echo executable is:

```text
bin/echo
```

---

## Testing

The test suite is located at:

```text
tests/echo/test_echo.sh
```

Run it with:

```bash
./tests/echo/test_echo.sh
```

The test suite covers:

- Basic string output
- Multiple arguments
- Empty invocation
- Empty arguments
- `-n`
- Repeated `-n`
- `-e`
- `-E`
- Combined options
- Option ordering
- Backslash escapes
- Newline
- Tab
- Carriage return
- Form feed
- Vertical tab
- Alert
- Backspace
- Escape character
- Octal escapes
- Hexadecimal escapes
- Mixed octal and hexadecimal escapes
- Unknown escapes
- Incomplete hexadecimal escapes
- Invalid hexadecimal escapes
- Trailing backslashes
- Invalid option-like arguments

Current test result:

```text
Tests passed: 36
Tests failed: 0
```

---

## Concepts Learned

Implementing `echo` introduced several C and Unix programming concepts.

### Command-line arguments

```c
int main(int argc, char *argv[])
```

`argc` contains the number of command-line arguments and `argv` contains the argument strings.

---

### C strings

Arguments in `argv` are null-terminated character arrays.

Characters can be accessed individually:

```c
text[i]
```

The end of a C string is identified by:

```c
'\0'
```

---

### Character processing

The implementation processes strings one character at a time.

For example:

```c
if (text[i] != '\\') {
    putchar(text[i]);
}
```

---

### Escape characters

C provides character constants such as:

```c
'\n'
'\t'
'\r'
'\b'
```

These represent control characters rather than printable text.

The ESC character is emitted using its ASCII value:

```c
putchar(27);
```

---

### `putchar()`

`putchar()` writes a single character to standard output.

It is useful for escape processing because the output may consist of characters that are generated dynamically.

---

### `fputs()`

When escape interpretation is disabled, the implementation can directly write the argument:

```c
fputs(argv[i], stdout);
```

---

### Numeric base conversion

Octal and hexadecimal escape sequences introduced manual numeric conversion.

Octal uses base 8:

```text
value = value * 8 + digit
```

Hexadecimal uses base 16:

```text
value = value * 16 + digit
```

This provides practical experience with parsing textual representations of numbers.

---

## Design Decisions

### Why custom option parsing?

`echo` accepts clustered options such as:

```text
-ne
-en
-nnn
```

while also treating unrecognized option-like arguments as normal text.

Therefore, a custom parser was more appropriate for this implementation than `getopt()`.

### Why process escapes without modifying `argv`?

The program reads the original argument strings and writes the interpreted result directly to standard output.

This avoids modifying the strings supplied through `argv` and keeps the escape-processing logic isolated inside `print_escaped()`.

---

## Known Limitations

This implementation is intended as a learning-oriented Unix utility rather than a guaranteed byte-for-byte replacement for every implementation of `echo`.

Differences can exist between:

- Bash's `echo`
- GNU `/usr/bin/echo`
- POSIX `echo`
- Other Unix implementations

The project intentionally focuses on understanding the underlying programming concepts while reproducing the selected Linux/GNU-style behavior.

---

## Status

**Status: Complete**

Implemented functionality:

- [x] Basic output
- [x] Multiple arguments
- [x] `-n`
- [x] `-e`
- [x] `-E`
- [x] Combined options
- [x] Simple escape sequences
- [x] Octal escapes
- [x] Hexadecimal escapes
- [x] Unknown escape handling
- [x] Edge-case testing
- [x] Automated test suite
- [x] Documentation

`echo` is now complete for the current project scope.
