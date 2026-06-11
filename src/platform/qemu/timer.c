#include "arch/riscv32/mmio.h"
#include "eugene/types.h"
#include <platform/qemu/memory_map.h>
#include <arch/riscv32/csr.h>
#include <stdio.h>


#define FREQUENCY 10000000
#define FREQUENCY_MS 10000

static inline void csr_enable_machine_timer_interrupt(void)
{
    unsigned long x = 1 << 7;
    __asm__ volatile ("csrs mie, %0" :: "r"(x));
}

void alarm_millis(u32 millis) {
	// TODO: Use 64 bits here.
	// Currently alarm_seconds can take max
	// 7.15 minutes. But this is enough for now.
	u32 delay = millis * (FREQUENCY_MS);
	unsigned int cmp_lo, cmp_hi;
	add_u64_parts(CLINT_MTIME_LO, CLINT_MTIME_HI, delay, 0, &cmp_lo, &cmp_hi);

    CLINT_MTIMECMP_LO = 0xffffffff;
	CLINT_MTIMECMP_HI = cmp_hi;
	CLINT_MTIMECMP_LO = cmp_lo;
	
}



void setup_timer() {
	CLINT_MTIMECMP_HI = MAX_U32;
	csr_enable_interrupts();
	csr_enable_machine_timer_interrupt();

}
