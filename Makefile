CC = gcc

CFLAGS = -std=c17 -Wall -Wextra -Wpedantic -Werror -g -O0

TARGET = bin/pwd
SOURCE = src/pwd/pwd.c

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(SOURCE) -o $(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: clean
