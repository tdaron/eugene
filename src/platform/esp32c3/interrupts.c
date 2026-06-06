#include "arch/riscv32/csr.h"
#ifdef ESP32
#include <platform/esp32c3/memory_map.h>

void set_interrupt_threshold(u32 threshold) {
  INTR_CPU_THRESH = threshold;
}
void route_interrupt(volatile u32 *interrupt, u32 trap_number, u32 priority) {
  csr_disable_interrupts();
  *interrupt = trap_number;
  INTR_CPU_TYPE &= ~(1u << trap_number);
  INTR_CPU_PRI(trap_number) = priority;
  INTR_CPU_ENABLE |= (1u << trap_number);
  csr_enable_interrupts();

}

void route_timg0_t0_interrupt(void) {
  csr_disable_interrupts();

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

  csr_enable_interrupts();
}
#endif
