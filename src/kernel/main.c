#include <common.h>


void kernel_main() {
	printf("Hello from C code ! \n");
	// printf("Trying to trap !\n");
	printf("My favorite number is %d\n", 67);

	__asm__ volatile(
	"ecall\n"
	);
	printf("done !\n");
}


void trap_unknown() {
    u32 mcause = READ_CSR(mcause);
    u32 mtval = READ_CSR(mtval);
    u32 mepc = READ_CSR(mepc);
    PANIC("unexpected trap mcause=%x, mtval=%x, mepc=%x\n", mcause, mtval, mepc);
}
