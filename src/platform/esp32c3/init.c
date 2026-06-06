#ifdef ESP32
#include <common.h>

#define REG32(a) (*(volatile u32 *)(a))

#define INTR_BASE 0x600C2000u /* ESP32-C3 interrupt matrix base */

#define INTR_TG_T0_MAP REG32(INTR_BASE + 0x080)
#define INTR_CPU_ENABLE REG32(INTR_BASE + 0x104)
#define INTR_CPU_TYPE REG32(INTR_BASE + 0x108)
#define INTR_CPU_THRESH REG32(INTR_BASE + 0x194)
#define INTR_CPU_PRI(n) REG32(INTR_BASE + 0x118 + 4 * ((n) - 1))

#define TIMG0_BASE 0x6001F000

#define TIMG0_T0_CONF REG32(TIMG0_BASE + 0x0)
#define TIMG0_T0_ALARMLO REG32(TIMG0_BASE + 0x10)
#define TIMG0_T0_ALARMHI REG32(TIMG0_BASE + 0x14)
#define TIMG0_T0_LOADLO REG32(TIMG0_BASE + 0x18)
#define TIMG0_T0_LOADHI REG32(TIMG0_BASE + 0x1C)
#define TIMG0_T0_LOAD REG32(TIMG0_BASE + 0x20)
#define TIMG0_INT_CLR REG32(TIMG0_BASE + 0x7C)
#define TIMG0_REGCLK REG32(TIMG0_BASE + 0xFC)

#define TIMG_WDTCONFIG0 REG32(TIMG0_BASE + 0x48)
#define TIMG_WDTWPROTECT REG32(TIMG0_BASE + 0x64)

#define TIMG0_INT_ENA_TIMERS REG32(TIMG0_BASE + 0x70)
#define TIMG0_INT_CLR_TIMERS REG32(TIMG0_BASE + 0x7C)

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

static inline void irq_global_enable(void) {
  __asm__ volatile("csrsi mstatus, 8" ::: "memory"); /* MIE = bit 3 */
}

static inline void irq_global_disable(void) {
  __asm__ volatile("csrci mstatus, 8" ::: "memory");
}

void route_timg0_t0_interrupt(void) {
  irq_global_disable();

  int CPU_INT_TG0_T0 = 1;

  /* Route peripheral source TG_T0_INT to CPU interrupt 1 */
  INTR_TG_T0_MAP = CPU_INT_TG0_T0;

  /* Level-triggered CPU interrupt */
  INTR_CPU_TYPE &= ~(1u << CPU_INT_TG0_T0);

  /* Priority must be nonzero */
  INTR_CPU_PRI(CPU_INT_TG0_T0) = 1;

  /* Allow priority 1 interrupts through */
  INTR_CPU_THRESH = 0;

  /* Enable CPU interrupt 1 */
  INTR_CPU_ENABLE |= (1u << CPU_INT_TG0_T0);

  irq_global_enable();
}

__attribute__((constructor)) void enable_t0_timer() {
  route_timg0_t0_interrupt();

  // TIMG_T0_EN (bit 31) - stop timer
  mmio_write_field(&TIMG0_T0_CONF, 31, 1, 0);

  // Enable timer group timer clock.
  mmio_write_field(&TIMG0_REGCLK, 30, 1, 1); // TIMG_TIMER_CLK_IS_ACTIVE

  // set XTAL
  mmio_write_field(&TIMG0_T0_CONF, 9, 1, 1);

  // Set the prescaler 
  mmio_write_field(&TIMG0_T0_CONF, 13, (28 - 13) + 1, 50);

  // Reset divider after changing it, while timer is disabled.
  mmio_write_field(&TIMG0_T0_CONF, 12, 1, 1); // TIMG_T0_DIVIDER_RST

  // Set the timer to increase
  mmio_write_field(&TIMG0_T0_CONF, 30, 1, 1);

  // Init timer at 0
  TIMG0_T0_LOADLO = 0;
  TIMG0_T0_LOADHI = 0;

  // reload values
  TIMG0_T0_LOAD = 1;

  TIMG0_T0_ALARMLO = 1000000;
  TIMG0_T0_ALARMHI = 0;

  TIMG0_INT_ENA_TIMERS = 0b01; // enable T0 interrupts
  // TIMG0_INT_CLR_TIMERS = 1;
  // TIMG0_INT_ENA_TIMERS |= 1;

  // TIMG_T0_ALARM_EN (bit 10)
  mmio_write_field(&TIMG0_T0_CONF, 10, 1, 1);

  // TIMG_T0_AUTORELOAD (bit 29)
  mmio_write_field(&TIMG0_T0_CONF, 29, 1, 1);

  // TIMG_T0_EN (bit 31) - start timer
  mmio_write_field(&TIMG0_T0_CONF, 31, 1, 1);

  printf("[ESP32C] Timer enabled.\n");
}

void clear_timer() {
  mmio_write_field(&TIMG0_INT_CLR_TIMERS, 0, 1, 1);
  mmio_write_field(&TIMG0_T0_CONF, 10, 1, 1);

}

#endif
