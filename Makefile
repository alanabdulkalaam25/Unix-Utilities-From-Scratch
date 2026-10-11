CC = gcc

CFLAGS = -std=c17 -Wall -Wextra -Wpedantic -Werror -g -O0

TARGETS = bin/pwd bin/echo

all: $(TARGETS)

bin/pwd: src/pwd/pwd.c
	$(CC) $(CFLAGS) $< -o $@

bin/echo: src/echo/echo.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGETS)

.PHONY: all clean
