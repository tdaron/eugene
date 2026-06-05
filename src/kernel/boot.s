# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start

_start:
        la sp, __stack_top # setup stack pointer
                 
        la a0, booted
        call printf

        call call_constructors
        call kernel_main

loop:
        wfi
        j loop




.section .rodata
booted: .string "[KERNEL] Hello ! \n"
constr: .string "[KERNEL] Calling init functions.\n"
