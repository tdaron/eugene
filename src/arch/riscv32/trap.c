#include <eugene/types.h>
#include <eugene/macros.h>
#include "trap.h"
#include <platform/platform.h>

void timer_interrupt() {
  printf("[KERNEL] Timer \n");
  alarm_millis(500);
}

void trap_handler(TrapFrame *tf) {
    if (tf->mcause == 11) {
        printf("ecall\n");
        tf->mepc += 4;
        return;
    }

    if (tf->mcause == 0x80000007) {
        return timer_interrupt();
    }

    PANIC("unexpected trap mcause=0x%x, mtval=0x%x, mepc=0x%x",
          tf->mcause, tf->mtval, tf->mepc);
}
