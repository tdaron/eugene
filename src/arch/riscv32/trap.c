#include "trap.h"
#include "eugene/tasks.h"
#include <eugene/macros.h>
#include <eugene/types.h>
#include <platform/platform.h>
#include <string.h>

// temporary malloc for now
extern char __heap_start[];
extern char __heap_end[];
u32 allocated = 0;

#define STACK_SIZE 2048

void *malloc(u32 size) {
  printf("size: %x allocated: %x\n", size, allocated);
  allocated += size;
  return __heap_start + allocated - size;
}

void *initial_task_trap_frame(void (*task)()) {
  // points to beginning of trap frame with STACK_SIZE below
  u8 *stack = malloc(STACK_SIZE + sizeof(TrapFrame)) + STACK_SIZE + sizeof(TrapFrame);
  stack = (u8 *)((u32)stack & ~0xFu); // 16-byte align

  TrapFrame *tf = (TrapFrame *)(stack - sizeof(TrapFrame));
  memset(tf, 0, sizeof(*tf));
  tf->sp = (u32)stack;
  tf->mepc = (u32)task;
  tf->mstatus = (3u << 11) | (1u << 7); // MPP=M, MPIE=1

  return tf;
}

void timer_interrupt() {
  alarm_millis(500);
}

void syscall(int syscall) {
  (void) syscall;
  __asm__ volatile("ecall");
}

TrapFrame* trap_handler(TrapFrame *tf) {
  if (tf->mcause == 11) {
    printf("ecall\n");
    tf->mepc += 4;

    if (tf->a0 == 67) {
      printf("start scheduler !\n");
      return (TrapFrame*)TASKS[0].tf;
    }

    return tf;
  }

  if (tf->mcause == 0x80000007) {
    timer_interrupt();
    TASKS[running_task].tf = (u32*)tf;
    running_task = (running_task + 1) % task_count;
    // printf("switching to task: %d tf: %x\n", running_task, tf);
    return (TrapFrame*)TASKS[running_task].tf;
  }

  PANIC("unexpected trap mcause=0x%x, mtval=0x%x, mepc=0x%x", tf->mcause,
        tf->mtval, tf->mepc);
}
