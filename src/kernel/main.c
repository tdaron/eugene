#include <arch/riscv32/csr.h> // TODO: Remove arch depenency here
#include <eugene/macros.h>
#include <eugene/types.h>
#include <platform/platform.h>

void timer_interrupt() {
  printf("[KERNEL] Timer \n");
  alarm_millis(500);
}

void trap_handler() {
  u32 mcause = READ_CSR(mcause);
  u32 mtval = READ_CSR(mtval);
  u32 mepc = READ_CSR(mepc);
  if (mcause == 0x80000007) {
    return timer_interrupt();
  }
  PANIC("unexpected trap mcause=%x, mtval=%x, mepc=%x\n", mcause, mtval, mepc);
}


typedef void (*constructor)();

extern constructor __init_array_start[];
extern constructor __init_array_end[];

// This function will call every
// constructor annotated with
//  __attribute__((constructor))
//
void call_constructors() {
  for (constructor *ctor = __init_array_start; ctor < __init_array_end;
       ctor++) {
    (*ctor)();
  }
}

void kernel_main() {
  init_platform();
  setup_traps();
  call_constructors();
  printf("[KERNEL] Booting..\n");
  printf("[KERNEL] Platform: %s\n", platform_name);
  alarm_millis(500);
  printf("[KERNEL] Done !\n");
}
