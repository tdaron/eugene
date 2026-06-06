# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start, trap_routine, trap_unknown

_start:
        la sp, __stack_top # setup stack pointer
        call kernel_main

loop:
        wfi
        j loop

.balign 4
trap_routine:
        addi sp, sp, -16
        sw t0, 12(sp)
        sw t1, 8(sp)

        csrr t0, mcause
        li t1, 11            # ECALL from M-mode
        bne t0, t1, trap_unknown        

        la a0, trap
        call printf
        
        csrr t0, mepc
        addi t0, t0, 4       # ecall is 4 bytes
        csrw mepc, t0

        lw t1, 8(sp)
        lw t0, 12(sp)
        addi sp, sp, 16
        mret


.section .rodata
booted: .string "[KERNEL] Hello ! \n"
trap: .string "[KERNEL] SOME TRAP HERE \n"
