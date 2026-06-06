#include <common.h>


void kernel_main() {
	printf("Hello from C code ! \n");
	// printf("Trying to trap !\n");
	printf("My favorite number is %d\n", 67);

	__asm__ volatile(
	"ecall\n"
	);
}


void kernel_trap() {
    u32 scause = READ_CSR(mcause);
    u32 stval = READ_CSR(mtval);
    u32 user_pc = READ_CSR(mepc);
    PANIC("unexpected trap scause=%x, stval=%x, sepc=%x\n", scause, stval, user_pc);
}
