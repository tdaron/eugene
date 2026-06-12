#ifdef ESP32
#include "platform/platform.h"
#include <platform/esp32c3/memory_map.h>
#include <platform/esp32c3/interrupts.h>


void alarm_millis(u32 millis) {
  
}

void disable_timg0_wdt(void) {
  TIMG_WDTWPROTECT = WDT_UNLOCK_KEY;
  TIMG_WDTCONFIG0 = 0;
  TIMG_WDTWPROTECT = 0;
}

void enable_t0_timer() {
  set_interrupt_threshold(0);
  route_interrupt(&INTR_TG_T0_MAP, 1, 1);

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
}

void clear_timer() {
  mmio_write_field(&TIMG0_INT_CLR_TIMERS, 0, 1, 1);
  mmio_write_field(&TIMG0_T0_CONF, 10, 1, 1);

}
#endif
