#ifdef ESP32
#include <common.h>

#define REG32(a) (*(volatile u32 *)(a))

#define TIMG0_BASE 0x6001F000
#define TIMG_WDTCONFIG0 REG32(TIMG0_BASE + 0x48)
#define TIMG_WDTWPROTECT REG32(TIMG0_BASE + 0x64)

#define WDT_UNLOCK_KEY 0x50D83AA1

#define USB_SERIAL_BASE 0x60043000
#define USB_SERIAL_FIFO REG32(USB_SERIAL_BASE + 0x0)
#define USB_SERIAL_CONF_REG REG32(USB_SERIAL_BASE + 0x4)
static void delay(volatile unsigned long n) {
  while (n--) {
    __asm__ volatile("nop");
  }
}
__attribute__((constructor)) void disable_timg0_wdt(void) {
  TIMG_WDTWPROTECT = WDT_UNLOCK_KEY;
  TIMG_WDTCONFIG0 = 0;
  TIMG_WDTWPROTECT = 0;
  delay(500000);
}

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
