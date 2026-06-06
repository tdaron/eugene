#include <eugene/types.h>
#include <eugene/macros.h>
#include <strings.h>
#include <arch/riscv32/csr.h> // TODO: Remove arch depenency here
#include <platform/platform.h>

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

void kernel_main() {
	init_platform();
	setup_traps();
	call_constructors();
	printf("[KERNEL] Booting..\n");
	printf("[KERNEL] Done !\n");
}
