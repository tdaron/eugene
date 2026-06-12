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
        addi sp, sp, -64

        sw ra, 60(sp)
        sw t0, 56(sp)
        sw t1, 52(sp)
        sw a0, 48(sp)
        sw a1, 44(sp)
        sw a2, 40(sp)
        sw a3, 36(sp)
        sw a4, 32(sp)
        sw a5, 28(sp)
        sw a6, 24(sp)
        sw a7, 20(sp)

        csrr t0, mcause
        li t1, 11            # ECALL from M-mode
        beq t0, t1, handle_ecall        
handle_other:
        call trap_handler
        j trap_return
handle_ecall:
        la a0, trap
        call printf
        
        csrr t0, mepc
        addi t0, t0, 4       # ecall is 4 bytes
        csrw mepc, t0

trap_return:
        lw a7, 20(sp)
        lw a6, 24(sp)
        lw a5, 28(sp)
        lw a4, 32(sp)
        lw a3, 36(sp)
        lw a2, 40(sp)
        lw a1, 44(sp)
        lw a0, 48(sp)
        lw t1, 52(sp)
        lw t0, 56(sp)
        lw ra, 60(sp)
        
        addi sp, sp, 64
        mret


.section .rodata
booted: .string "[KERNEL] Hello ! \n"
trap: .string "[KERNEL] SOME TRAP HERE \n"
