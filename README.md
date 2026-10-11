# Unix Utilities From Scratch

A learning project focused on **reimplementing common Unix/Linux command-line utilities from scratch in C**.

The goal is to strengthen understanding of **C programming, Linux/POSIX APIs, system calls, filesystems, processes, and command-line tools** by building utilities instead of simply using them.

## Utilities

Completed: 

- `pwd`
- `echo`

Currently In Progress:

- `cat`

Planned:

- `mkdir`
- `rmdir`
- `touch`
- `ls`
- `cp`
- `mv`
- `rm`
- `head`
- `tail`
- `wc`
- `grep`
- `find`
- and more

## Project Structure

```text
unix-utilities-from-scratch/
├── src/       # Utility implementations
├── tests/     # Tests
├── docs/      # Notes and documentation
├── bin/       # Compiled binaries
├── Makefile
├── README.md
└── .gitignore
```

## Environment

Developed and tested on:

- **RHEL 10**
- **GCC**
- **GNU Make**
- **GDB**
- **strace**
- **Git**

The utilities are intended for **Unix/Linux environments** and will primarily use standard C and POSIX/Linux APIs.

## Purpose

This project is primarily for **learning and systems programming practice**. The implementations are not intended to replace the original GNU/Unix utilities.

## License

MIT License
