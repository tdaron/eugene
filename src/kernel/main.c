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

void task() {
  printf("HEY I AM HERE !\n");

  while (1) {
  }
}

void kernel_main() {
  init_platform();
  setup_traps();
  printf("[KERNEL] Booting..\n");
  call_constructors();
  printf("[KERNEL] Platform: %s\n", platform_name);
  alarm_millis(500);
  printf("[KERNEL] Done !\n");
  printf("[KERNEL] %d bytes available RAM\n", __heap_end - __heap_start);
  create_task("Simple Task", task, 0);
}

__attribute__((constructor))
void zero_bss() {
  for (u32* i = __bss_start; i < __bss_end; i++) {
    *i = 0;
  }
  printf("[KERNEL] bss zeroed\n");
}
