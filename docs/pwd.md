# `pwd`

## 1. Purpose

`pwd` (print working directory) displays the path of the current working directory.

This implementation recreates the basic behavior of the Unix/Linux `pwd` utility in C, with support for logical and physical path resolution.

---

## 2. Implemented Behavior

The implementation supports:

| Command | Behavior |
|---|---|
| `./bin/pwd` | Prints the physical working directory |
| `./bin/pwd -L` | Prints the logical working directory using `$PWD` when valid |
| `./bin/pwd -P` | Prints the physical working directory |
| `./bin/pwd -LP` | Physical mode |
| `./bin/pwd -PL` | Logical mode |
| `./bin/pwd -X` | Invalid option; exits with a non-zero status |

### Option precedence

When both `-L` and `-P` are supplied, the **last option takes precedence**.

For example:

```bash
./bin/pwd -LP
```

uses physical mode because `-P` is last.

```bash
./bin/pwd -PL
```

uses logical mode because `-L` is last.

---

## 3. Logical vs Physical Paths

A logical path preserves symbolic links used when navigating to the current directory.

A physical path resolves symbolic links and identifies the actual directory on the filesystem.

For example:

```text
/home/alan25/project-link
        │
        └──→ /home/alan25/unix-utilities-from-scratch
```

If the shell's current directory was entered through `project-link`:

```bash
pwd -L
```

can produce:

```text
/home/alan25/project-link
```

while:

```bash
pwd -P
```

produces:

```text
/home/alan25/unix-utilities-from-scratch
```

---

## 4. Implementation Details

### 4.1 `getopt()`

The program uses `getopt()` to parse the `-L` and `-P` options.

```c
while ((option = getopt(argc, argv, "LP")) != -1)
```

This provides support for:

- individual options;
- combined options such as `-LP`;
- option ordering;
- invalid-option detection.

The program tracks the selected mode with:

```c
int logical = 0;
```

`0` represents physical mode and `1` represents logical mode.

---

### 4.2 `getenv()`

Logical mode uses the `PWD` environment variable:

```c
const char *pwd = getenv("PWD");
```

`PWD` normally contains the logical path maintained by the shell.

However, the program does **not** blindly trust it.

---

### 4.3 `$PWD` Validation

Before using `$PWD`, the program verifies that it actually refers to the current directory.

It obtains filesystem information for both:

```text
.
```

and:

```text
$PWD
```

using `stat()`.

The program compares:

```c
current.st_dev == logical_dir.st_dev
```

and:

```c
current.st_ino == logical_dir.st_ino
```

Both must match.

This verifies that `$PWD` and the current directory refer to the same filesystem object.

If `$PWD` is invalid, the program falls back to `getcwd()`.

---

### 4.4 `getcwd()`

Physical path resolution is performed with:

```c
getcwd(buffer, sizeof(buffer))
```

`getcwd()` obtains the current working directory from the operating system and resolves symbolic links.

The result is stored in a fixed-size buffer:

```c
char buffer[4096];
```

If `getcwd()` fails, the program reports the error using:

```c
perror("pwd");
```

and exits with status `1`.

---

### 4.5 `stat()`

The implementation uses `stat()` to validate `$PWD`.

`stat()` follows symbolic links and provides information about the filesystem object being referenced.

The relevant fields are:

```c
st_dev
st_ino
```

- `st_dev` identifies the filesystem/device containing the object.
- `st_ino` identifies the inode of the object within that filesystem.

Together, they allow the program to verify that two paths refer to the same directory.

---

## 5. Feature-Test Macro

The source begins with:

```c
#define _POSIX_C_SOURCE 200809L
```

This enables the required POSIX interfaces when compiling under strict C17 mode.

It is required for the declaration of `getopt()` in this build environment.

The program is compiled with:

```bash
gcc -std=c17 -Wall -Wextra -Wpedantic -Werror -g -O0 src/pwd/pwd.c -o bin/pwd
```

---

## 6. Error Handling

The program handles the following error cases.

### Invalid option

For example:

```bash
./bin/pwd -X
```

`getopt()` detects the invalid option and the program exits with status `2`.

### `getcwd()` failure

If the physical working directory cannot be obtained:

```c
perror("pwd");
return 1;
```

The operating system error is displayed through `perror()`.

### Invalid `$PWD`

If `$PWD` does not refer to the current directory, logical mode does not use it.

Instead, the implementation falls back to `getcwd()`.

---

## 7. Exit Statuses

| Status | Meaning |
|---:|---|
| `0` | Successful execution |
| `1` | Failed to obtain the working directory |
| `2` | Invalid command-line option |

---

## 8. Testing

The `pwd` implementation has a dedicated test script:

```text
tests/
└── pwd/
    └── test_pwd.sh
```

The test suite verifies:

- default behavior;
- `-L`;
- `-P`;
- combined options;
- option precedence;
- invalid options;
- symbolic-link handling;
- `$PWD` validation;
- fallback to physical resolution.

Current test result:

```text
Tests passed: 13
Tests failed: 0
```

All 13 tests currently pass.

---

## 9. Test Environment

The symbolic-link tests create temporary directories dynamically using:

```bash
mktemp -d
```

The test environment contains:

```text
temporary directory/
├── real/
└── link → real
```

This allows the test suite to verify the difference between logical and physical paths without committing test data to the repository.

The temporary environment is removed automatically when the test finishes.

---

## 10. Current Limitations

This implementation is intended as an educational recreation rather than a complete replacement for GNU/Coreutils `pwd`.

Current limitations include:

- Uses a fixed `4096`-byte path buffer.
- Does not implement `--help`.
- Does not implement `--version`.
- Does not implement GNU long-option handling.
- Only implements the `-L` and `-P` options required for the current project scope.
- Behavior is intentionally limited to the concepts being studied in this project.

---

## 11. Concepts Learned

The `pwd` implementation introduced several Linux/POSIX and systems-programming concepts:

- POSIX feature-test macros
- `getopt()`
- command-line option parsing
- environment variables
- `getenv()`
- `getcwd()`
- `stat()`
- filesystem device numbers
- inode numbers
- symbolic links
- logical vs physical paths
- `errno` and `perror()`
- process exit statuses
- shell `$PWD` behavior
- C string buffers and the NUL terminator
- system-call/libc interaction
- basic `strace` usage
- automated shell-based testing

---

## 12. Scope of the Implementation

The `pwd` utility establishes the foundation for the rest of the project by introducing the interaction between C programs, the Linux filesystem, environment variables, command-line arguments, and POSIX APIs.

The implementation is intentionally kept small and focused so that each Linux-specific concept can be understood before moving to the next utility.
