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

#endif
