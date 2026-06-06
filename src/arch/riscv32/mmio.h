#pragma once
#include <eugene/types.h>

#define MMIO32(a) (*(volatile u32 *)(a))
static inline void mmio_write_field(
    volatile u32 *reg,
    unsigned shift,
    unsigned width,
    u32 value
) {
    u32 mask = ((1 << width) - 1) << shift;

    u32 r = *reg;
    r &= ~mask;
    r |= (value << shift) & mask;
    *reg = r;
}
