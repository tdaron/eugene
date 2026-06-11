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

static inline void add_u64_parts(
    u32 a_lo,
    u32 a_hi,
    u32 b_lo,
    u32 b_hi,
    u32 *out_lo,
    u32 *out_hi
) {
    u32 lo = a_lo + b_lo;
    u32 carry = (lo < a_lo);

    u32 hi = a_hi + b_hi + carry;

    *out_lo = lo;
    *out_hi = hi;
}
