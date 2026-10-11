#include <stdio.h>

void print_escaped(const char *text) {
  for (int i = 0; text[i] != '\0'; i++) {
    if (text[i] != '\\') {
      putchar(text[i]);
      continue;
    }

    i++;

    if (text[i] == '\0') {
      putchar('\\');
      break;
    }

    switch (text[i]) {
    case '0': {
      int value = 0;

      for (int j = 0; j < 3 && text[i + 1] >= '0' && text[i + 1] <= '7'; j++) {
        i++;
        value = value * 8 + (text[i] - '0');
      }

      putchar(value);
      break;
    }
    case 'x': {
      int value = 0;
      int digits = 0;

      while (digits < 2) {
        char c = text[i + 1];

        if (c >= '0' && c <= '9') {
          value = value * 16 + (c - '0');
        } else if (c >= 'a' && c <= 'f') {
          value = value * 16 + (c - 'a' + 10);
        } else if (c >= 'A' && c <= 'F') {
          value = value * 16 + (c - 'A' + 10);
        } else {
          break;
        }

        i++;
        digits++;
      }

      if (digits == 0) {
        putchar('\\');
        putchar('x');
      } else {
        putchar(value);
      }

      break;
    }
    case '\\':
      putchar('\\');
      break;

    case 'a':
      putchar('\a');
      break;

    case 'b':
      putchar('\b');
      break;

    case 'e':
      putchar(27);
      break;

    case 'f':
      putchar('\f');
      break;

    case 'n':
      putchar('\n');
      break;

    case 'r':
      putchar('\r');
      break;

    case 't':
      putchar('\t');
      break;

    case 'v':
      putchar('\v');
      break;

    default:
      putchar('\\');
      putchar(text[i]);
      break;
    }
  }
}

int main(int argc, char *argv[]) {
  int newline = 1;
  int interpret_escapes = 0;

  int i = 1;

  while (i < argc) {
    const char *arg = argv[i];

    if (arg[0] != '-' || arg[1] == '\0') {
      break;
    }

    int valid_option = 1;

    for (int j = 1; arg[j] != '\0'; j++) {
      switch (arg[j]) {
      case 'n':
        newline = 0;
        break;

      case 'e':
        interpret_escapes = 1;
        break;

      case 'E':
        interpret_escapes = 0;
        break;

      default:
        valid_option = 0;
        break;
      }

      if (!valid_option) {
        break;
      }
    }

    if (!valid_option) {
      break;
    }

    i++;
  }

  int first_argument = 1;

  for (; i < argc; i++) {
    if (!first_argument) {
      putchar(' ');
    }

    if (interpret_escapes) {
      print_escaped(argv[i]);
    } else {
      fputs(argv[i], stdout);
    }
    first_argument = 0;
  }

  if (newline) {
    putchar('\n');
  }

  return 0;
}
