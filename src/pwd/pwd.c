#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int option;
  int logical = 0;

  while ((option = getopt(argc, argv, "LP")) != -1) {
    switch (option) {
    case 'L':
      logical = 1;
      break;

    case 'P':
      logical = 0;
      break;

    case '?':
      return 2;
    }
  }

  if (logical) {
    const char *pwd = getenv("PWD");

    if (pwd != NULL) {
      struct stat current;
      struct stat logical_dir;

      if (stat(".", &current) == 0 && stat(pwd, &logical_dir) == 0 &&
          current.st_dev == logical_dir.st_dev &&
          current.st_ino == logical_dir.st_ino) {
        printf("%s\n", pwd);
        return 0;
      }
    }
  }

  char buffer[4096];

  if (getcwd(buffer, sizeof(buffer)) == NULL) {
    perror("pwd");
    return 1;
  }

  fputs(buffer, stdout);
  fputc('\n', stdout);

  return 0;
}
