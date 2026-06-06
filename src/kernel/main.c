#include <common.h>

void call_constructors();
void setup_traps();

void kernel_main() {
	call_constructors();
	printf("[KERNEL] Booting..\n");
	printf("[KERNEL] Registering traps..\n");
	setup_traps();
	printf("[KERNEL] Boot successfull !\n");
}


void trap_unknown() {
    u32 mcause = READ_CSR(mcause);
    u32 mtval = READ_CSR(mtval);
    u32 mepc = READ_CSR(mepc);
    PANIC("unexpected trap mcause=%x, mtval=%x, mepc=%x\n", mcause, mtval, mepc);
}
