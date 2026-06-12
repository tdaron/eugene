#include <eugene/macros.h>
#include <eugene/tasks.h>
#include <eugene/types.h>
#include <platform/platform.h>


typedef void (*constructor)();

extern constructor __init_array_start[];
extern constructor __init_array_end[];
extern u32 __bss_start[];
extern u32 __bss_end[];
extern char __heap_start[];
extern char __heap_end[];

void hello_rust();

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

void delay() {
  #ifdef QEMU
  for (int i = 0; i < 500000000; i++) {
    __asm__ volatile ("add x0, x0, x0");
  }
  #elif ESP32
  for (int i = 0; i < 1000000; i++) {
    __asm__ volatile ("add x0, x0, x0");
  }

  #else
  for (int i = 0; i < 100000; i++) {
    __asm__ volatile ("add x0, x0, x0");
  }

  #endif
}
void taskA() {
  while (1) {
    printf("TASK A !\n");
    delay();
  }
}
void taskB() {
  while (1) {
    printf("TASK B !\n");
    delay();
  }
}

void kernel_main() {
  init_platform();
  setup_traps();
  printf("[KERNEL] Booting..\n");
  printf("calling constructors\n");
  call_constructors();
  printf("done\n");
  printf("[KERNEL] Platform: %s\n", platform_name);
  alarm_millis(500);
  printf("[KERNEL] %d bytes available RAM\n", __heap_end - __heap_start);
  printf("[KERNEL] Done !\n");
  hello_rust();
  printf("here\n");
  create_task("Simple Task", taskA, 0);
  create_task("Simple Task 2", taskB, 0);
  printf("%x\n", TASKS[0].tf);
  printf("%x\n", TASKS[1].tf);
  syscall(67);
}

__attribute__((constructor))
void zero_bss() {
  printf("[bss start]: %x\n", __bss_start);
  printf("[bss end]: %x\n", __bss_end);
  for (u32* i = __bss_start; i < __bss_end; i++) {
    *i = 0;
  }
  printf("[KERNEL] bss zeroed\n");
}
