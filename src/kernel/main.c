#include <common.h>

void call_constructors();
void setup_traps();

void kernel_main() {
	setup_traps();
	call_constructors();
	printf("[KERNEL] Booting..\n");
	printf("[KERNEL] Done !\n");
}


void trap_unknown() {
    u32 mcause = READ_CSR(mcause);
    u32 mtval = READ_CSR(mtval);
    u32 mepc = READ_CSR(mepc);
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


