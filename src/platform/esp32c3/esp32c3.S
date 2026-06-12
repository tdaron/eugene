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

        j trap_routine    # timer
        .rept 30
        j trap_routine         # slots 1..31: interrupts
        .endr
.option pop


timer_routine:
        call clear_timer
        li a0, 0x80000007
        csrw mcause, a0
        j trap_routine



#endif
