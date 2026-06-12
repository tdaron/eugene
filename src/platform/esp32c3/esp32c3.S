#ifdef ESP32
.global setup_traps


setup_traps:
        

        la a0, trap_vector
        ori a0, a0, 1          # vectored mode bit
        csrw mtvec, a0
        ret

.balign 256
trap_vector:
.option push
.option norvc              # force 4-byte entries in the vector table
        j trap_routine      # slot 0: exceptions, including ecall

        j timer_routine
        .rept 30
        j trap_handler         # slots 1..31: interrupts
        .endr
.option pop


timer_routine:
        addi sp, sp, -16
        sw a0, 12(sp)
        sw ra, 8(sp)
        call clear_timer
        la a0, timer
        call printf
        lw a0, 12(sp)
        lw ra, 8(sp)
        addi sp, sp, 16
        mret

timer: .string "[ESP32] Timer !\n"


#endif
