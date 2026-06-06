#pragma once

#include <eugene/types.h>

static inline u32 csr_read_mstatus(void)
{
    u32 v;
    __asm__ volatile ("csrr %0, mstatus" : "=r"(v));
    return v;
}

static inline void csr_write_mstatus(u32 v)
{
    __asm__ volatile ("csrw mstatus, %0" :: "r"(v));
}

static inline void csr_enable_interrupts(void)
{
    __asm__ volatile ("csrsi mstatus, 8");
}

static inline void csr_disable_interrupts(void)
{
    __asm__ volatile ("csrci mstatus, 8");
}

static inline void csr_wfi(void)
{
    __asm__ volatile ("wfi");
}

#define READ_CSR(reg)                                                          \
    ({                                                                         \
        unsigned long __tmp;                                                   \
        __asm__ __volatile__("csrr %0, " #reg : "=r"(__tmp));                  \
        __tmp;                                                                 \
    })

#define WRITE_CSR(reg, value)                                                  \
    do {                                                                       \
        u32 __tmp = (value);                                              \
        __asm__ __volatile__("csrw " #reg ", %0" ::"r"(__tmp));                \
    } while (0)
