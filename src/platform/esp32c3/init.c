#include "platform/platform.h"
#ifdef ESP32
#include <platform/esp32c3/memory_map.h>
#include <platform/esp32c3/interrupts.h>

void disable_timg0_wdt(void);
void enable_t0_timer();

static void delay(volatile unsigned long n) {
  while (n--) {
    __asm__ volatile("nop");
  }
}

void init_platform() {
  delay(500000);
  disable_timg0_wdt();
  enable_t0_timer();
}

char platform_name[] = "esp32c3";       



#endif
