#pragma once

#include <arch/riscv32/mmio.h>


// DOC: https://sifive.cdn.prismic.io/sifive%2Fc89f6e5a-cf9e-44c3-a3db-04420702dcc1_sifive+e31+manual+v19.08.pdf
// CLINT memory map page 24

#define CLINT_BASE      0x02000000
#define CLINT_MTIMECMP_LO  MMIO32(CLINT_BASE + 0x4000)
#define CLINT_MTIMECMP_HI  MMIO32(CLINT_BASE + 0x4000 + 4)

#define CLINT_MTIME_LO     MMIO32(CLINT_BASE + 0xBFF8)
#define CLINT_MTIME_HI     MMIO32(CLINT_BASE + 0xBFF8 + 4)
