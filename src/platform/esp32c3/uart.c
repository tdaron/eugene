#ifdef ESP32
#include <platform/esp32c3/memory_map.h>


void putc(char a) {
  while (!(USB_SERIAL_CONF_REG & 0b10)) {
  }

  if (a == '\n') {
    USB_SERIAL_FIFO = '\r';
    USB_SERIAL_FIFO = '\n';

    USB_SERIAL_CONF_REG = 0b001;
  } else {
    USB_SERIAL_FIFO = a;
  }
}
#endif
