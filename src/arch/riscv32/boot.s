# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start, trap_routine, trap_unknown

_start:
        la sp, __stack_top # setup stack pointer
        call kernel_main
loop:
        wfi
        j loop


.section .rodata
booted: .string "[KERNEL] Hello ! \n"
trap: .string "[KERNEL] SOME TRAP HERE \n"
