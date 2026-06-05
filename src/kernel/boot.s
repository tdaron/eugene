# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start

_start:
        la sp, __stack_top # setup stack pointer
                 
        la a0, booted
        call printf

        call call_constructors

        la a0, trap_routine
        call setup_traps # platform specific

        call kernel_main

loop:
        wfi
        j loop


trap_routine:
        addi sp, sp, -16
        sw ra, 12(sp)
        call kernel_trap
        lw ra, 12(sp)
        addi sp, sp, 16
l:
        j l
.section .rodata
booted: .string "[KERNEL] Hello ! \n"
