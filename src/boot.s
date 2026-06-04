# https://luplab.gitlab.io/rvcodecjs
.section .text.boot
.global _start
.global __heap_start
.global __heap_end


.equ MTIMECMP_LO,  0x11004000
.equ MTIMECMP_HI,  0x11004004
.equ MTIME_LO,     0x1100bff8
.equ MTIME_HI,     0x1100bffc

_start:
        la sp, __stack_top # setup stack pointer
        # csrw 0x137, sp
                 
        la a0, booted
        call print
        la t0, trap_entry
        csrw mtvec, t0

        call setup_timer
        call call_constructors
        call kernel_main

loop:
        wfi
        j loop


setup_timer:
    addi sp, sp, -16
    sw ra, 12(sp)
    call timer_set_next
    li t0, 0x80 # mie.MTIE
    csrs mie, t0
    
    li t0, 0x8
    csrs mstatus, t0
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

timer_set_next:
    li t0, MTIME_LO
    lw t1, 0(t0)

    li t2, 2500000
    add t1, t1, t2

    li t0, MTIMECMP_HI
    li t2, -1
    sw t2, 0(t0)

    li t0, MTIMECMP_LO
    sw t1, 0(t0)

    li t0, MTIMECMP_HI
    sw zero, 0(t0)

    ret
        
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


trap_entry:
        li t0, 67
        mv a1, ra
        la a0, trap0
        call print
        call timer_set_next
        mv ra, a1
        # csrr t0, mepc
        # addi t0, t0, 4
        # csrw mepc, t0
        mret

.section .rodata
booted: .string "[KERNEL] Hello ! \n"
trap0: .string "[KERNEL] Timer Interrupt ! \n"
func: .string "Registered function.\n"
constr: .string "[KERNEL] Calling init functions.\n"
