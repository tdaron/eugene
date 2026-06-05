# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start

_start:
        la sp, __stack_top # setup stack pointer
                 
        la a0, booted
        call print

        call call_constructors
        call kernel_main

loop:
        wfi
        j loop


call_constructors:
        addi sp, sp, -16
        sw ra, 12(sp)
        sw s0, 8(sp)
        sw s1, 4(sp)
        sw s2, 0(sp)

        la s0, __init_array_start
        la s1, __init_array_end
        la a0, constr

        call print

1:
        beq s0, s1, 2f
        lw s2, 0(s0)
        addi s0, s0, 4
        jalr ra, 0(s2)
        j 1b
2:
        lw s0, 8(sp)
        lw s1, 4(sp)
        lw s2, 0(sp)
        lw ra, 12(sp)
        addi sp, sp, 16
        ret


.section .rodata
booted: .string "[KERNEL] Hello ! \n"
constr: .string "[KERNEL] Calling init functions.\n"
