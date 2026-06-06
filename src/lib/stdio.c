#include <eugene/types.h>
#include <stdio.h>
#include <string.h>

void printf(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);

  int length = strlen(fmt);
  for (int i = 0; i < length; i++) {
    char c = fmt[i];
    if (c != '%' || i == length - 1) {
      putc(c);
      continue;
    }
    if (fmt[i + 1] == '%') {
      putc(c);
      i += 1;
      continue;
    }

    if (fmt[i + 1] == 's') {
      i += 1;
      char *s = va_arg(args, char *);
      while (*(s++)) {
        putc(*(s - 1));
      }
    }

    if (fmt[i + 1] == 'd') {
      i += 1;
      int value = va_arg(args, int);
      unsigned magnitude = value;
      if (value < 0) {
        putc('-');
        magnitude = -magnitude;
      }

      unsigned divisor = 1;
      while (magnitude / divisor > 9)
        divisor *= 10;

      while (divisor > 0) {
        putc('0' + magnitude / divisor);
        magnitude %= divisor;
        divisor /= 10;
      }
    }
    if (fmt[i + 1] == 'x') {
      printf("0x");
      i++;
      unsigned value = va_arg(args, unsigned);
      for (int i = 7; i >= 0; i--) {
        unsigned nibble = (value >> (i * 4)) & 0xf;
        putc("0123456789abcdef"[nibble]);
      }
    }
  }
}



