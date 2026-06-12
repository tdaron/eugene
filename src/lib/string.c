#include <string.h>

int strlen(const char *string) {
  int i;
  for (i = 0; string[i]; i++) {
  };
  return i;
}

void memset(void* ptr, char value, u32 size) {
  for (u32 i = 0; i < size; i++) {
    ((char*)ptr)[i] = value;
  }
}
